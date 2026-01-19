# frozen_string_literal: true

require_relative "markdown/linkify"

module Hoe::Halostatue::Markdown
  # Specify which markdown files to linkify.
  #
  # Should always be a list. May contain `:default` or `{exclude: patterns}` for special
  # handling.
  #
  # `:default` ensures that all `.md` files in the manifest are included.
  #
  # `{exclude: patterns}` excludes files matching any of the provided patterns (a glob
  # string, a regular expression, or a list of glob strings or regular expressions).
  #
  # [default: `[:default]`, any markdown files found in `spec.files`]
  attr_accessor :markdown_linkify_files

  # The style for producing links. The options are:
  #
  # - `:reference`, which will produce named reference links (e.g., `[#123][gh-issue-123]`)
  # - `:inline`, which produces inline links (e.g., `[#123](https://…)`)
  #
  # Existing links _will not be modified_.
  #
  # When using reference links, existing reference link definitions will not be moved, but
  # new definitions will be appended to the end of the file.
  attr_accessor :markdown_linkify_style

  # Controls whether shortened URIs for the current repository have prefixes added to
  # them. This is either falsy (no prefixes added), `true` default prefixes are added, or
  # a map with one or more type (`issue`, `pull`, `discussion`) and the prefix to be
  # applied. The default prefixes (when `true`) are
  # `{issue: 'issue', pull: 'pull', discussion: 'discussion'}`.
  #
  # Examples (assuming `true`):
  #
  # ```markdown
  # [issue #123](https://github.com/cogswellcogs/sprocketkiller/issues/123
  # [pull #246](https://github.com/cogswellcogs/sprocketkiller/pull/246)
  # [discussion #369](https://github.com/cogswellcogs/sprocketkiller/discussions/369)
  # ```
  attr_accessor :markdown_linkify_uri_prefixes

  private

  def default_markdown_linkify_files
    spec.files.grep(/\.md$/)
  end

  def initialize_halostatue_markdown
    self.markdown_linkify_files = [:default]
    self.markdown_linkify_style = :reference
    self.markdown_linkify_uri_prefixes = nil

    # TODO: We should check for `Changelog.md`, `ChangeLog.md` and `History.md`, etc., as
    # documented

    if File.exist?("CHANGELOG.md")
      self.history_file = "CHANGELOG.md"
    end

    # TODO: Be case insensitive here, too

    if File.exist?("README.md")
      self.readme_file = "README.md"
    end
  end

  def define_halostatue_markdown_tasks
    return unless resolve_linkify_options

    namespace_name = "markdown:linkify"
    linkify_tasks = []

    namespace namespace_name do
      markdown_linkify_files.each do |mdfile_path|
        mdfile_name = File.basename(mdfile_path)
        task_name = mdfile_name.downcase.split(".")[0..-2].join(".")

        linkifier = Hoe::Halostatue::Markdown::Linkify.new(
          bug_tracker_uri: spec.metadata["bug_tracker_uri"],
          style: markdown_linkify_style,
          uri_prefixes: markdown_linkify_uri_prefixes
        )

        desc "hyperlink github issues and usernames in #{mdfile_name}"
        task task_name do
          original_markdown = File.read(mdfile_path)

          linkifier.linkify(original_markdown) => {markdown:, changed:}

          if changed
            puts "markdown:linkify: updating #{mdfile_path}"
            File.write(mdfile_path, markdown)
          else
            puts "markdown:linkify: no changes to #{mdfile_path}"
          end
        end

        linkify_tasks << "#{namespace_name}:#{task_name}"
      end
    end

    desc "hyperlink github issues and usernames in markdown files"
    task namespace_name => linkify_tasks
  end

  def resolve_linkify_options
    unless [:reference, :inline].include? markdown_linkify_style
      raise ArgumentError, "Invalid markdown_linkify_style: #{markdown_linkify_style.inspect}"
    end

    self.markdown_linkify_uri_prefixes =
      Hoe::Halostatue::Markdown::Linkify.normalize_uri_prefixes(markdown_linkify_uri_prefixes)

    resolve_linkify_files
  end

  def resolve_linkify_files
    @markdown_linkify_files ||= [:default]
    return false if markdown_linkify_files.empty?

    exclude_patterns =
      markdown_linkify_files
        .select { _1.is_a?(Hash) && _1.key?(:exclude) }
        .flat_map { Array(_1[:exclude]) }.uniq

    unless exclude_patterns.all? { _1.is_a?(Regexp) || _1.is_a?(String) }
      raise ArgumentError, "exclude patterns must be Regexp or String"
    end

    markdown_linkify_files.reject! { _1.is_a?(Hash) }

    if markdown_linkify_files.include?(:default)
      markdown_linkify_files
        .concat(default_markdown_linkify_files)
        .delete(:default)
    end

    markdown_linkify_files.flatten!

    markdown_linkify_files.reject! do |file|
      exclude_patterns.any? { |pattern|
        pattern.is_a?(Regexp) ? file.match?(pattern) : File.fnmatch?(pattern, file)
      }
    end

    markdown_linkify_files.uniq!
    !markdown_linkify_files.empty?
  end
end
