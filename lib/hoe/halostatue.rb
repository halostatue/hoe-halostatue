# frozen_string_literal: true

require_relative "halostatue/version"
require_relative "halostatue/checklist"
require_relative "halostatue/gemspec"
require_relative "halostatue/git"
require_relative "halostatue/markdown"

class Hoe; end # :nodoc:

Hoe.plugins.delete :git
Hoe.plugins.delete :newb
Hoe.plugins.delete :publish
Hoe.plugins.delete :signing

# This module is a Hoe plugin which applies extremely opinionated reconfiguration to Hoe.
# You can set its options in your Rakefile Hoe spec, like this:
#
# ```ruby
# Hoe.plugin :halostatue
#
# Hoe.spec "myproj" do
#   self.checklist = nil if ENV["rubygems_release_gem"] == "true"
#   self.git_release_tag_prefix = "REL_"
#   self.git_remotes << "myremote"
# end
# ```
#
# The `:git` plugin (built into Hoe since Hoe 4.5 or present in the `hoe-git` or
# `hoe-git2` dependencies) should not be enabled as that implementation differs from what
# is included here.
#
# ### Tasks
#
# - `checklist`: Show the list of checklist questions.
# - `git:manifest`: Update the manifest with Git's file list.
# - `git:tag`: Create and push a tag.
#
# ### Options
#
# - `checklist`: An array of reminder questions that should be asked before a release, in
#   the form "Did you... [question]?". The default questions are:
#
#   - `Bump the version?`
#   - `Check everything in?`
#   - `Review the manifest?`
#   - `Update the README and docs?`
#   - `Update the changelog?`
#   - `Regenerate the gemspec?`
#
#   If the checklist is `nil` or empty, or trusted publishing is on, the checklist will
#   not be shown.
#
# - `git_release_tag_prefix`: What do you want at the front of your release tags? The
#   default is `"v"`.
#
# - `git_remotes`: Which remotes do you want to push tags, etc. to? The default is
#   `%w[origin]`.
#
# - `git_tag_enabled`: Whether a git tag should be created on release. The default is
#   `true`.
#
# - `reproducible_gemspec`: Whether a fixed date should be used for reproducible gemspec
#   values. This is ignored if `$SOURCE_DATE_EPOCH` is set. Acceptable values are:
#
#   - `:default` or `true`: uses the RubyGems default source date epoch
#   - `:current`: uses the date stored in the most recent gemspec file
#   - `false`: sets the release date to the current date
#   - An epoch value, either as an Integer or a String
#
#   The default is `:default`.
#
# - `trusted_release`: Indicates that this release is being run as part of a trusted
#   release workflow.
module Hoe::Halostatue
  include Hoe::Halostatue::Checklist
  include Hoe::Halostatue::Gemspec
  include Hoe::Halostatue::Git
  include Hoe::Halostatue::Markdown

  # Indicates that this release is being run as part of a trusted release workflow.
  # [default: `false`]
  attr_accessor :trusted_release

  def initialize_halostatue # :nodoc:
    initialize_halostatue_checklist
    initialize_halostatue_gemspec
    initialize_halostatue_git
    initialize_halostatue_markdown

    self.trusted_release = false
  end

  def define_halostatue_tasks # :nodoc:
    if trusted_release
      task :trusted_release do
        vm = %r{^(?<version>\d+(?:\.\d+)+)(?:\.(?<pre>[a-z]\w+(?:\.\d+)+))?}
          .match(spec.version.to_s)

        ENV["VERSION"] = vm[:version]
        ENV["PRERELEASE"] = vm[:pre]
      end

      task release_sanity: :trusted_release
    end

    define_halostatue_checklist_tasks
    define_halostatue_gemspec_tasks
    define_halostatue_git_tasks
    define_halostatue_markdown_tasks
  end

  private

  ::Hoe::URLS_TO_META_MAP.update({
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

  # This replaces Hoe#parse_urls with something that works better for Markdown.
  module ParseUrls # :nodoc:
    def parse_urls text
      keys = Hoe::URLS_TO_META_MAP.keys.join("|")
      pattern = %r{^[-+*]\s+(#{keys})\s+::\s+<?(\w+://[^>\s]+)>?}m

      text.scan(pattern).to_h
    end

    ::Hoe.prepend self
  end
end
