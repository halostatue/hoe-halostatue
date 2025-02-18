# frozen_string_literal: true

require "shellwords"
require_relative "halostatue/version"

Hoe.plugin :gemspec2
Hoe.plugin :markdown
Hoe.plugin :rubygems

# This module is a Hoe plugin. You can set its options in your Rakefile Hoe spec, like
# this:
#
#    Hoe.plugin :git
#
#    Hoe.spec "myproj" do
#      self.checklist = nil if ENV["rubygems_release_gem"] == "true"
#      self.git_release_tag_prefix = "REL_"
#      self.git_remotes << "myremote"
#    end
#
# === Tasks
#
# git:changelog:: Print the current changelog.
# git:manifest::  Update the manifest with Git's file list.
# git:tag::       Create and push a tag.
#
# === Options
#
# - +checklist+: An array of reminder questions that should be asked before a release, in
#   the form, "Did you... [question]?" You can see the defaults by running <tt>rake
#   checklist</tt>. If the checklist is +nil+ or empty, the checklist will not shown
#   during release. This is originally from hoe-doofus and called +doofus_checklist+.
#
# - +git_release_tag_prefix+: What do you want at the front of your release tags? The
#   default is <tt>"v"</tt>.
#
# - +git_remotes+: Which remotes do you want to push tags, etc. to? The default is
#   <tt>%w[origin]</tt>
#
# - +git_tag_enabled+: Whether a git tag should be created on release. The default is
#   +true+.
module Hoe::Halostatue
  # Indicates that this release is being run as part of a trusted release workflow.
  # [default: +false+]
  attr_accessor :trusted_release

  # An array of reminder questions that should be asked before a release, in the form,
  # "Did you... [question]?" You can see the defaults by running <tt>rake checklist</tt>.
  #
  # If the checklist is +nil+ or empty, the checklist will not shown during release.
  attr_accessor :checklist

  # What do you want at the front of your release tags?
  # [default: <tt>"v"</tt>]
  attr_accessor :git_release_tag_prefix

  # Which remotes do you want to push tags, etc. to?
  # [default: <tt>%w[origin]</tt>]
  attr_accessor :git_remotes

  # Should git tags be created on release? [default: +true+]
  attr_accessor :git_tag_enabled

  def initialize_halostatue # :nodoc:
    Hoe::URLS_TO_META_MAP.update({
      "bugs" => "bug_tracker_uri",
      "changelog" => "changelog_uri",
      "changes" => "changelog_uri",
      "clog" => "changelog_uri",
      "code" => "source_code_uri",
      "doco" => "documentation_uri",
      "docs" => "documentation_uri",
      "documentation" => "documentation_uri",
      "history" => "changelog_uri",
      "home" => "homepage_uri",
      "issues" => "bug_tracker_uri",
      "mail" => "mailing_list_uri",
      "tickets" => "bug_tracker_uri",
      "wiki" => "wiki_uri"
    })
    Hoe.prepend Hoe::Halostatue::ParseUrls

    self.checklist = [
      "bump the version",
      "check everything in",
      "review the manifest",
      "update the README and RDocs",
      "update the changelog",
      "regenerate the gemspec"
    ]

    self.git_release_tag_prefix = "v"
    self.git_remotes = %w[origin]
    self.git_tag_enabled = true
    self.trusted_release = false
  end

  def define_halostatue_tasks # :nodoc:
    desc "Show a reminder for steps I frequently forget"
    task :checklist do
      if checklist.nil? || checklist.empty?
        puts "Checklist is empty."
      else
        puts "\n### HEY! Did you...\n\n"

        checklist.each do |question|
          question = question[0..0].upcase + question[1..]
          question = "#{question}?" unless question.end_with?("?")
          puts "  * #{question}"
        end

        puts
      end
    end

    task :release_sanity do
      unless checklist.nil? || checklist.empty? || trusted_release
        Rake::Task[:checklist].invoke
        puts "Hit return if you're sure, Ctrl-C if you forgot something."
        $stdin.gets
      end
    end

    task :spec_clean_markdown_text do
      spec.description =
        spec.description.gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')
          .gsub(/\[([^\]]+)\]\[[^\]]+\]/, '\1')

      spec.summary =
        spec.summary.gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')
          .gsub(/\[([^\]]+)\]\[[^\]]+\]/, '\1')
    end

    task "#{spec.name}.gemspec" => :spec_clean_markdown_text

    if trusted_release
      task :trusted_release do
        vm = %r{^(?<version>\d+(?:\.\d+)+)(?:\.(?<pre>[a-z]\w+(?:\.\d+)+))?}
          .match(spec.version.to_s)

        ENV["VERSION"] = vm[:version]
        ENV["PRERELEASE"] = vm[:pre]
      end

      task release_sanity: :trusted_release
    end

    return unless __run_git("rev-parse", "--is-inside-work-tree") == "true"

    desc "Update the manifest with Git's file list. Use Hoe's excludes."
    task "git:manifest" do
      with_config do |config, _|
        files = __run_git("ls-files").split($/)
        files.reject! { |f| f =~ config["exclude"] }

        File.open "Manifest.txt", "w" do |f|
          f.puts files.sort.join("\n")
        end
      end
    end

    desc "Create and push a TAG (default #{git_release_tag_prefix}#{version})."
    task "git:tag" do
      if git_tag_enabled
        tag = ENV["TAG"]
        ver = ENV["VERSION"] || version
        pre = ENV["PRERELEASE"] || ENV["PRE"]
        ver += ".#{pre}" if pre
        tag ||= "#{git_release_tag_prefix}#{ver}"

        git_tag_and_push tag
      end
    end

    task :release_sanity do
      unless __run_git("status", "--porcelain").empty?
        abort "Won't release: Dirty index or untracked files present!"
      end
    end

    task release_to: "git:tag"
  end

  def __git(command, *params)
    "git #{command.shellescape} #{params.compact.shelljoin}"
  end

  def __run_git(command, *params)
    `#{__git(command, *params)}`.strip.chomp
  end

  def git_svn?
    File.exist?(File.join(__run_git("rev-parse", "--show-toplevel"), ".git/svn"))
  end

  def git_tag_and_push tag
    msg = "Tagging #{tag}."

    if git_svn?
      sh __git("svn", "tag", tag, "-m", msg)
    else
      flags =
        if __run_git("config", "--get", "user.signingkey").empty?
          nil
        else
          "-s"
        end

      sh __git("tag", flags, "-f", tag, "-m", msg)
      git_remotes.each { |remote| sh __git("push", "-f", remote, "tag", tag) }
    end
  end

  # This replaces Hoe#parse_urls with something that works better for Markdown.
  module ParseUrls # :nodoc:
    def parse_urls text
      keys = Hoe::URLS_TO_META_MAP.keys.join("|")
      pattern = %r{^[-+*]\s+(#{keys})\s+::\s+[<]?(\w+://[^>\s]+)[>]?}m

      text.scan(pattern).to_h
    end
  end
end
