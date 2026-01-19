# frozen_string_literal: true

require "kramdown"
require "set"

class Hoe
  module Halostatue
    module Markdown
    end
  end
end

class Hoe::Halostatue::Markdown::Linkify # :nodoc:
  # Match GitHub username (@username) but not email addresses or Mastodon handles
  # Basic pattern - additional validation done post-match
  USERNAME_PATTERN = %r{
    (?<![A-Za-z0-9])      # Not preceded by alphanumeric (prevents email match)
    @                      # Literal @ sign
    ([A-Za-z0-9-]{1,39})   # 1-39 chars of alphanumeric or hyphen
    (?![-A-Za-z0-9@])      # Not followed by alphanumeric, hyphen, or @ (prevents Mastodon/email)
  }x

  def self.linkify_file(filename, ...)
    new(...).linkify(File.read(filename))
  end

  def self.linkify(source, ...)
    new(...).linkify(source)
  end

  def self.normalize_uri_prefixes(prefixes)
    case prefixes
    when true
      {issue: "issue", pull: "pull request", discussion: "discussion"}
    when false, nil
      {}
    else
      extra = prefixes.keys - %i[issue pull discussion]

      if extra.empty?
        prefixes
      else
        raise ArgumentError, "Extra keys for markdown_linkify_uri_prefixes: #{extra.inspect}"
      end
    end
  end

  def initialize(bug_tracker_uri: nil, style: :reference, uri_prefixes: {})
    @bug_tracker_uri = bug_tracker_uri
    @repo_owner, @repo_name = extract_repo_info(bug_tracker_uri)
    @style = style
    @uri_prefixes = self.class.normalize_uri_prefixes(uri_prefixes)
  end

  def linkify(source)
    scan_existing_references(source) => {existing_by_key:, existing_by_ref:}
    new_by_key = {}
    new_by_ref = {}
    replacements = []
    processed_positions = Set.new

    doc = Kramdown::Document.new(source, input: "GFM")

    walk(doc.root) do |element, ancestors|
      next unless element.type == :text
      next if in_skip_context?(ancestors)

      text = element.value

      # Find this text occurrence in source that we haven't processed yet
      source_offset = 0
      while (text_pos = source.index(text, source_offset))
        break if processed_positions.include?(text_pos)

        # Mark this position as processed
        processed_positions.add(text_pos)

        # Scan for patterns in this text occurrence
        scan_usernames(source, text, text_pos, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
        scan_owner_repo_issues(source, text, text_pos, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
        scan_issue_mentions(source, text, text_pos, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
        scan_github_uris(source, text, text_pos, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
        scan_github_repo_uris(source, text, text_pos, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
        scan_github_user_uris(source, text, text_pos, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)

        break # Only process first unprocessed occurrence
      end
    end

    return {markdown: source, changed: false} if replacements.empty?

    # Apply replacements in reverse
    result = source.dup

    replacements.reverse_each do |r|
      result[r[:start]...r[:end]] = r[:replacement]
    end

    # Append new references if using reference style
    if @style == :reference && !new_by_key.empty?
      result = append_references(result, new_by_key)
    end

    {markdown: result, changed: true}
  end

  private

  def extract_repo_info(uri)
    return [nil, nil] unless uri

    match = uri.match(%r{github\.com/([^/]+)/([^/]+)})
    match ? [match[1], match[2]] : [nil, nil]
  end

  def walk(element, ancestors = [], &block)
    new_ancestors = ancestors + [element]
    yield element, ancestors
    element&.children&.each { |child| walk(child, new_ancestors, &block) }
  end

  def in_skip_context?(ancestors)
    ancestors.any? { |el| %i[codeblock codespan a html_element].include?(el.type) }
  end

  def scan_existing_references(source)
    existing_by_key = {}
    existing_by_ref = {}

    source.scan(/^\[([^\]]+)\]:\s*(.+)$/) do |key, uri|
      existing_by_key[key] = uri.strip
      existing_by_ref[uri.strip] ||= key
    end

    {existing_by_key:, existing_by_ref:}
  end

  def scan_usernames(source, text, base_offset, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
    offset = 0

    while (match = text.match(USERNAME_PATTERN, offset))
      pos = base_offset + match.begin(0)
      username = match[1]

      # Validate username
      next offset = pos + match[0].length unless valid_username?(username)

      # Check the actual source to ensure no consecutive hyphens follow
      # (kramdown may split text nodes at typographic symbols like --)
      source_match = source[pos, username.length + 3]
      next offset = pos + match[0].length if source_match&.include?("--")

      next offset = pos + match[0].length if already_linked?(source, pos)
      next offset = pos + match[0].length if overlaps_replacement?(replacements, pos, match[0].length)

      uri = "https://github.com/#{username}"
      link_text = "@#{username}"
      ref_base = "gh-user-#{username}"

      replacement = if @style == :reference
        ref_id = find_or_create_ref_id(ref_base, uri, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
        "[#{link_text}][#{ref_id}]"
      else
        "[#{link_text}](#{uri})"
      end

      replacements << {start: pos, end: pos + match[0].length, replacement:}
      offset = pos + match[0].length
    end
  end

  def scan_issue_mentions(source, text, base_offset, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
    return unless @repo_owner && @repo_name

    pattern = /#(\d+)(?=\s|$|[^\d])/
    offset = 0

    while (match = text.match(pattern, offset))
      pos = base_offset + match.begin(0)
      number = match[1]

      next offset = pos + match[0].length if already_linked?(source, pos)
      next offset = pos + match[0].length if overlaps_replacement?(replacements, pos, match[0].length)

      uri = "https://github.com/#{@repo_owner}/#{@repo_name}/issues/#{number}"
      link_text = "##{number}"
      ref_base = "gh-issue-#{number}"

      replacement = if @style == :reference
        ref_id = find_or_create_ref_id(ref_base, uri, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
        "[#{link_text}][#{ref_id}]"
      else
        "[#{link_text}](#{uri})"
      end

      replacements << {start: pos, end: pos + match[0].length, replacement:}
      offset = pos + match[0].length
    end
  end

  def scan_github_uris(source, text, base_offset, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
    pattern = %r{https://github\.com/([A-Za-z0-9_-]+)/([A-Za-z0-9_-]+)/(issues|pull|discussions)/(\d+)(?:#(issuecomment|discussioncomment|discussion_r)-?(\d+))?([?#][^\s)]*)?}
    offset = 0

    while (match = text.match(pattern, offset))
      pos = base_offset + match.begin(0)
      owner = match[1]
      repo = match[2]
      type = match[3]
      number = match[4]
      comment_type = match[5]
      comment_id = match[6]
      extra_fragment = match[7]

      next offset = pos + match[0].length if already_linked?(source, pos)
      next offset = pos + match[0].length if overlaps_replacement?(replacements, pos, match[0].length)

      # Build URI (preserve all fragments and query params)
      uri = "https://github.com/#{owner}/#{repo}/#{type}/#{number}"
      if comment_type
        separator = (comment_type == "discussion_r") ? "" : "-"
        uri += "##{comment_type}#{separator}#{comment_id}"
      end
      uri += extra_fragment if extra_fragment

      # Build link text
      is_same_repo = @repo_owner == owner && @repo_name == repo
      link_text = is_same_repo ? "##{number}" : "#{owner}/#{repo}##{number}"

      # Add comment indicator for comment fragments
      if comment_type
        link_text += (comment_type == "discussion_r") ? " (review comment)" : " (comment)"
      end

      # Apply prefix if configured
      type_key = case type
      when "issues" then :issue
      when "pull" then :pull
      when "discussions" then :discussion
      end

      if is_same_repo && type_key && @uri_prefixes[type_key]
        link_text = "#{@uri_prefixes[type_key]} #{link_text}"
      end

      replacement = if @style == :reference
        ref_base = is_same_repo ? "gh-issue-#{number}" : "gh-#{owner}-#{repo}-#{number}"
        ref_id = find_or_create_ref_id(ref_base, uri, existing_by_key, existing_by_ref, new_by_key, new_by_ref, comment_id)
        "[#{link_text}][#{ref_id}]"
      else
        "[#{link_text}](#{uri})"
      end

      replacements << {start: pos, end: pos + match[0].length, replacement:}
      offset = pos + match[0].length
    end
  end

  def scan_owner_repo_issues(source, text, base_offset, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
    pattern = %r{([A-Za-z0-9_-]+)/([A-Za-z0-9_-]+)#(\d+)(?=\s|$|[^\d])}
    offset = 0

    while (match = text.match(pattern, offset))
      pos = base_offset + match.begin(0)
      owner = match[1]
      repo = match[2]
      number = match[3]

      next offset = pos + match[0].length if already_linked?(source, pos)
      next offset = pos + match[0].length if overlaps_replacement?(replacements, pos, match[0].length)

      uri = "https://github.com/#{owner}/#{repo}/issues/#{number}"
      link_text = "#{owner}/#{repo}##{number}"
      ref_base = "gh-#{owner}-#{repo}-#{number}"

      replacement = if @style == :reference
        ref_id = find_or_create_ref_id(ref_base, uri, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
        "[#{link_text}][#{ref_id}]"
      else
        "[#{link_text}](#{uri})"
      end

      replacements << {start: pos, end: pos + match[0].length, replacement:}
      offset = pos + match[0].length
    end
  end

  def scan_github_user_uris(source, text, base_offset, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
    pattern = %r{https://github\.com/([A-Za-z0-9_-]+)(?=/|\s|$)}
    offset = 0

    while (match = text.match(pattern, offset))
      pos = base_offset + match.begin(0)
      username = match[1]

      next offset = pos + match[0].length unless valid_username?(username)
      next offset = pos + match[0].length if already_linked?(source, pos)
      next offset = pos + match[0].length if overlaps_replacement?(replacements, pos, match[0].length)

      uri = "https://github.com/#{username}"
      link_text = "@#{username}"
      ref_base = "gh-user-#{username}"

      replacement = if @style == :reference
        ref_id = find_or_create_ref_id(ref_base, uri, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
        "[#{link_text}][#{ref_id}]"
      else
        "[#{link_text}](#{uri})"
      end

      replacements << {start: pos, end: pos + match[0].length, replacement:}
      offset = pos + match[0].length
    end
  end

  def scan_github_repo_uris(source, text, base_offset, replacements, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
    pattern = %r{https://github\.com/([A-Za-z0-9_-]+)/([A-Za-z0-9_-]+)(?=/|\s|$)}
    offset = 0

    while (match = text.match(pattern, offset))
      pos = base_offset + match.begin(0)
      owner = match[1]
      repo = match[2]

      next offset = pos + match[0].length if already_linked?(source, pos)
      next offset = pos + match[0].length if overlaps_replacement?(replacements, pos, match[0].length)

      uri = "https://github.com/#{owner}/#{repo}"
      link_text = "#{owner}/#{repo}"
      ref_base = "gh-#{owner}-#{repo}"

      replacement = if @style == :reference
        ref_id = find_or_create_ref_id(ref_base, uri, existing_by_key, existing_by_ref, new_by_key, new_by_ref)
        "[#{link_text}][#{ref_id}]"
      else
        "[#{link_text}](#{uri})"
      end

      replacements << {start: pos, end: pos + match[0].length, replacement:}
      offset = pos + match[0].length
    end
  end

  def already_linked?(source, offset)
    # Check if preceded by [ or ]( within reasonable distance
    check_start = [offset - 100, 0].max
    preceding = source[check_start...offset]

    # If we find [text] or [text]( before our position, we're likely in a link
    if /\[[^\]]*\](?:\([^)]*)?$/.match?(preceding)
      return true
    end

    # Check if we're inside a link reference [text][ref] or inline link [text](url)
    if /\[[^\]]*$/.match?(preceding)
      return true
    end

    # Check if followed by ]
    following = source[offset, 10]
    if following&.match(/^[^\[]*\]/)
      return true
    end

    false
  end

  def overlaps_replacement?(replacements, start_pos, length)
    end_pos = start_pos + length
    replacements.any? { |r| (start_pos < r[:end]) && (end_pos > r[:start]) }
  end

  def make_ref_id(text, suffix = nil)
    base = text.gsub(/[^A-Za-z0-9-]/, "-").downcase.gsub(/^-+|-+$/, "")
    base = "#{base}-#{suffix}" if suffix
    base
  end

  def find_or_create_ref_id(link_text, uri, existing_by_key, existing_by_ref, new_by_key, new_by_ref, suffix = nil)
    # Check if URI already has a ref
    return existing_by_ref[uri] if existing_by_ref.key?(uri)
    return new_by_ref[uri] if new_by_ref.key?(uri)

    # Generate new unique ref ID
    base = make_ref_id(link_text, suffix)
    ref_id = base
    counter = 2

    while existing_by_key.key?(ref_id) || new_by_key.key?(ref_id)
      ref_id = "#{base}-#{counter}"
      counter += 1
    end

    # Register in both indexes
    new_by_key[ref_id] = uri
    new_by_ref[uri] = ref_id

    ref_id
  end

  def append_references(markdown, new_by_key)
    return markdown if new_by_key.empty?

    result = markdown.chomp

    if markdown.match?(/^\[.+?\]:\s+.+\z/m)
      result << "\n" unless result.end_with?("\n")
    else
      result << "\n\n" unless result.end_with?("\n\n")
    end

    new_by_key.each { |key, uri| result << "[#{key}]: #{uri}\n" }
    result
  end

  def valid_username?(username)
    return false if username.start_with?("-") || username.end_with?("-")
    return false if username.include?("--")
    return false if username.length > 39 || username.length < 1

    true
  end
end
