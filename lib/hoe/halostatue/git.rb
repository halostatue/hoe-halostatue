# frozen_string_literal: true

require "shellwords"

module Hoe::Halostatue::Git
  # What do you want at the front of your release tags?
  # [default: `"v"`]
  attr_accessor :git_release_tag_prefix

  # Which remotes do you want to push tags, etc. to?
  # [default: `%w[origin]`]
  attr_accessor :git_remotes

  # Should git tags be created on release? [default: `true`]
  attr_accessor :git_tag_enabled

  private

  def initialize_halostatue_git # :nodoc:
    self.git_release_tag_prefix = "v"
    self.git_remotes = %w[origin]
    self.git_tag_enabled = true
  end

  def define_halostatue_git_tasks # :nodoc:
    return unless __run_git("rev-parse", "--is-inside-work-tree") == "true"

    desc "Update the manifest with Git's file list. Use Hoe's excludes."
    task "git:manifest" do
      with_config do |config, _|
        files = __run_git("ls-files")
          .split($/)
          .grep_v(config["exclude"])

        File.write "Manifest.txt", files.sort.join("\n") + "\n"
      end
    end

    desc "Create and push a TAG (default #{git_release_tag_prefix}#{version})."
    task "git:tag" do
      if git_tag_enabled
        tag = ENV["TAG"]
        ver = ENV["VERSION"] || version
        pre = ENV["PRERELEASE"] || ENV["PRE"]
        ver += ".#{pre}" if pre && !ver.end_with?(pre)
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

    flags = "-s" unless __run_git("config", "--get", "user.signingkey").empty?

    sh __git("tag", flags, "-f", tag, "-m", msg)
    git_remotes.each { |remote| sh __git("push", "-f", remote, "tag", tag) }
  end
end
