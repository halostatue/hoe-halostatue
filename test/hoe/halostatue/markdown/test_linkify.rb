# frozen_string_literal: true

require "minitest_helper"
require "hoe/halostatue/markdown/linkify"

class TestHoeHalostatueMarkdownLinkify < Minitest::Test
  BUG_TRACKER_URI = "https://github.com/owner/repo/issues"

  private def linkify(source, **kwargs)
    Hoe::Halostatue::Markdown::Linkify.linkify(
      source,
      bug_tracker_uri: BUG_TRACKER_URI, **kwargs
    )
  end

  private def assert_unchanged(input, message: nil, **kwargs)
    expected = {markdown: input, changed: false}
    actual = linkify(input, **kwargs)

    assert_equal expected, actual,
      message(message || "Expected input and output to be the same", nil) { diff expected[:markdown], actual[:markdown] }
  end

  private def assert_changed(expected, input, message: nil, **kwargs)
    expected = {markdown: expected, changed: true}
    actual = linkify(input, **kwargs)

    assert_equal expected, actual,
      message(message || "Expected output to be different than input", nil) { diff expected[:markdown], actual[:markdown] }
  end

  def test_linkifies_usernames_with_reference_style
    input = "Thanks @example for the help!"
    expected = <<~MD
      Thanks [@example][gh-user-example] for the help!

      [gh-user-example]: https://github.com/example
    MD

    assert_changed expected, input
  end

  def test_linkifies_usernames_with_inline_style
    input = "Thanks @example for the help!"
    expected = "Thanks [@example](https://github.com/example) for the help!"

    assert_changed expected, input, style: :inline
  end

  def test_does_not_linkify_email_addresses
    input = "Email is user@example.com"
    assert_unchanged input
  end

  def test_linkifies_usernames_with_hyphens
    input = "Thanks @foo-bar-baz for the help!"
    expected = <<~MD
      Thanks [@foo-bar-baz][gh-user-foo-bar-baz] for the help!

      [gh-user-foo-bar-baz]: https://github.com/foo-bar-baz
    MD

    assert_changed expected, input
  end

  def test_linkifies_usernames_at_end_of_sentence
    input = "Hello @example."
    expected = <<~MD
      Hello [@example][gh-user-example].

      [gh-user-example]: https://github.com/example
    MD

    assert_changed expected, input
  end

  def test_linkifies_usernames_with_punctuation
    input = "See @alice, @bob; and @charlie!"
    expected = <<~MD
      See [@alice][gh-user-alice], [@bob][gh-user-bob]; and [@charlie][gh-user-charlie]!

      [gh-user-alice]: https://github.com/alice
      [gh-user-bob]: https://github.com/bob
      [gh-user-charlie]: https://github.com/charlie
    MD

    assert_changed expected, input
  end

  def test_does_not_linkify_username_with_trailing_hyphen
    input = "Not a user: @invalid-"
    assert_unchanged input
  end

  def test_does_not_linkify_username_with_leading_hyphen
    input = "Not a user: @-invalid"
    assert_unchanged input
  end

  def test_does_not_linkify_mastodon_handles
    input = "Follow me at @exemplar@example.com"
    assert_unchanged input
  end

  def test_does_not_linkify_username_with_consecutive_hyphens
    input = "Not valid: @foo--bar"
    assert_unchanged input
  end

  def test_linkifies_username_at_max_length
    username = "a" * 39
    input = "User @#{username} here"
    expected = <<~MD
      User [@#{username}][gh-user-#{username}] here

      [gh-user-#{username}]: https://github.com/#{username}
    MD

    assert_changed expected, input
  end

  def test_does_not_linkify_username_over_max_length
    username = "a" * 40
    input = "User @#{username} here"
    assert_unchanged input
  end

  def test_does_not_linkify_patterns_in_code_blocks_and_spans
    input = <<~MD
      See `@user` and `#123` inline.

      ```
      @another and #456 in block
      ```
    MD

    assert_unchanged input
  end

  def test_preserves_non_comment_fragments_in_github_urls
    input = "See https://github.com/owner/repo/issues/123#heading"
    expected = <<~MD
      See [#123][gh-issue-123]

      [gh-issue-123]: https://github.com/owner/repo/issues/123#heading
    MD

    assert_changed expected, input
  end

  def test_linkifies_same_pattern_in_different_contexts
    input = <<~MD
      See @alice and #123.

      But not `@alice` or `#123` in code.
    MD
    expected = <<~MD
      See [@alice][gh-user-alice] and [#123][gh-issue-123].

      But not `@alice` or `#123` in code.

      [gh-user-alice]: https://github.com/alice
      [gh-issue-123]: https://github.com/owner/repo/issues/123
    MD

    assert_changed expected, input
  end

  def test_handles_reference_id_collision
    input = <<~MD
      See @alice

      [gh-user-alice]: https://example.com/different-alice
    MD
    expected = <<~MD
      See [@alice][gh-user-alice-2]

      [gh-user-alice]: https://example.com/different-alice
      [gh-user-alice-2]: https://github.com/alice
    MD

    assert_changed expected, input
  end

  def test_does_not_linkify_github_urls_in_inline_code
    input = "See `https://github.com/owner/repo/issues/123` for details"
    assert_unchanged input
  end

  def test_does_not_linkify_autolinked_urls
    input = "See <https://github.com/owner/repo/issues/123>"
    assert_unchanged input
  end

  def test_does_not_linkify_patterns_in_square_brackets
    input = "Reference [@user] and [#123] here"
    assert_unchanged input
  end

  def test_linkifies_full_github_uris_without_bug_tracker_uri
    input = "See https://github.com/owner/repo/issues/123"
    expected = <<~MD
      See [owner/repo#123][gh-owner-repo-123]

      [gh-owner-repo-123]: https://github.com/owner/repo/issues/123
    MD

    assert_changed expected, input, bug_tracker_uri: nil
  end

  def test_does_not_linkify_issue_mentions_without_bug_tracker_uri
    assert_unchanged "Fixed in #123", bug_tracker_uri: nil
  end

  def test_does_not_linkify_issue_mentions_with_non_github_bug_tracker
    assert_unchanged "Fixed in #123", bug_tracker_uri: "https://bugs.example.com/issues"
  end

  def test_linkifies_bare_username_urls
    input = "See https://github.com/halostatue for details"
    expected = <<~MD
      See [@halostatue][gh-user-halostatue] for details

      [gh-user-halostatue]: https://github.com/halostatue
    MD

    assert_changed expected, input
  end

  def test_linkifies_repo_urls
    input = "Check out https://github.com/owner/repo"
    expected = <<~MD
      Check out [owner/repo][gh-owner-repo]

      [gh-owner-repo]: https://github.com/owner/repo
    MD

    assert_changed expected, input
  end

  def test_linkifies_owner_repo_issue_pattern
    input = "See owner/repo#123 for details"
    expected = <<~MD
      See [owner/repo#123][gh-owner-repo-123] for details

      [gh-owner-repo-123]: https://github.com/owner/repo/issues/123
    MD

    assert_changed expected, input
  end

  def test_preserves_query_parameters_in_github_urls
    input = "See https://github.com/owner/repo/issues/123?foo=bar"
    expected = <<~MD
      See [#123][gh-issue-123]

      [gh-issue-123]: https://github.com/owner/repo/issues/123?foo=bar
    MD

    assert_changed expected, input
  end

  def test_does_not_linkify_usernames_in_code_blocks
    input = <<~MD
      Check out this code:

      ```ruby
      # @example wrote this
      def foo
      end
      ```
    MD
    assert_unchanged input
  end

  def test_does_not_linkify_usernames_in_inline_code
    input = "Use `@example` as the username"
    assert_unchanged input
  end

  def test_does_not_linkify_usernames_already_in_links
    input = "See [@example](https://example.com)"
    assert_unchanged input
  end

  def test_reuses_existing_reference_for_same_username
    input = "Thanks @example and @example again!"
    expected = <<~MD
      Thanks [@example][gh-user-example] and [@example][gh-user-example] again!

      [gh-user-example]: https://github.com/example
    MD

    assert_changed expected, input
  end

  def test_reuses_existing_reference_definition_from_source
    input = <<~MD
      Thanks @example!

      [gh-user-example]: https://github.com/example
    MD
    expected = <<~MD
      Thanks [@example][gh-user-example]!

      [gh-user-example]: https://github.com/example
    MD

    assert_changed expected, input
  end

  def test_linkifies_issue_mentions_with_reference_style
    input = "Fixed in #123"
    expected = <<~MD
      Fixed in [#123][gh-issue-123]

      [gh-issue-123]: https://github.com/owner/repo/issues/123
    MD

    assert_changed expected, input
  end

  def test_linkifies_issue_mentions_with_inline_style
    input = "Fixed in #123"
    expected = "Fixed in [#123](https://github.com/owner/repo/issues/123)"

    assert_changed expected, input, style: :inline
  end

  def test_does_not_linkify_issue_mentions_in_code_blocks
    input = <<~MD
      ```ruby
      # Issue #123
      ```
    MD
    assert_unchanged input
  end

  def test_does_not_linkify_issue_mentions_in_inline_code
    input = "Use `#123` as reference"
    assert_unchanged input
  end

  def test_does_not_linkify_issue_mentions_already_in_links
    input = "See [#123](https://example.com)"
    assert_unchanged input
  end

  def test_reuses_existing_reference_for_same_issue
    input = "See #123 and #123 again"
    expected = <<~MD
      See [#123][gh-issue-123] and [#123][gh-issue-123] again

      [gh-issue-123]: https://github.com/owner/repo/issues/123
    MD

    assert_changed expected, input
  end

  def test_shortens_same_repo_issue_uris
    input = "See https://github.com/owner/repo/issues/123"
    expected = <<~MD
      See [#123][gh-issue-123]

      [gh-issue-123]: https://github.com/owner/repo/issues/123
    MD

    assert_changed expected, input
  end

  def test_shortens_same_repo_pr_uris
    input = "See https://github.com/owner/repo/pull/456"
    expected = <<~MD
      See [#456][gh-issue-456]

      [gh-issue-456]: https://github.com/owner/repo/pull/456
    MD

    assert_changed expected, input
  end

  def test_shortens_other_repo_uris_with_owner_repo_prefix
    input = "See https://github.com/other/project/issues/789"
    expected = <<~MD
      See [other/project#789][gh-other-project-789]

      [gh-other-project-789]: https://github.com/other/project/issues/789
    MD

    assert_changed expected, input
  end

  def test_handles_comment_fragments
    input = "See https://github.com/owner/repo/issues/123#issuecomment-456"
    expected = <<~MD
      See [#123 (comment)][gh-issue-123-456]

      [gh-issue-123-456]: https://github.com/owner/repo/issues/123#issuecomment-456
    MD

    assert_changed expected, input
  end

  def test_handles_discussion_uris
    input = "See https://github.com/owner/repo/discussions/999"
    expected = <<~MD
      See [#999][gh-issue-999]

      [gh-issue-999]: https://github.com/owner/repo/discussions/999
    MD

    assert_changed expected, input
  end

  def test_does_not_linkify_uris_already_in_links
    input = "[issue](https://github.com/owner/repo/issues/123)"
    assert_unchanged input
  end

  def test_does_not_linkify_uris_in_code_blocks
    input = <<~MD
      ```
      https://github.com/owner/repo/issues/123
      ```
    MD
    assert_unchanged input
  end

  def test_adds_prefixes_when_configured
    input = "See https://github.com/owner/repo/issues/123"
    expected = <<~MD
      See [issue #123][gh-issue-123]

      [gh-issue-123]: https://github.com/owner/repo/issues/123
    MD

    assert_changed expected, input, uri_prefixes: {issue: "issue", pull: "pull"}
  end

  def test_uses_default_prefixes_when_true
    input = "See https://github.com/owner/repo/pull/456"
    expected = <<~MD
      See [pull request #456][gh-issue-456]

      [gh-issue-456]: https://github.com/owner/repo/pull/456
    MD

    assert_changed expected, input, uri_prefixes: true
  end

  def test_does_not_linkify_text_in_reference_definitions
    input = <<~MD
      [#123]: https://github.com/owner/repo/issues/123
    MD
    assert_unchanged input
  end

  def test_appends_new_references_after_existing_content
    input = <<~MD
      See @example [existing][existing].

      [existing]: https://example.com
    MD
    expected = <<~MD
      See [@example][gh-user-example] [existing][existing].

      [existing]: https://example.com
      [gh-user-example]: https://github.com/example
    MD

    assert_changed expected, input
  end

  def test_handles_multiple_patterns_in_one_line
    input = "Thanks @example for fixing #123!"
    expected = <<~MD
      Thanks [@example][gh-user-example] for fixing [#123][gh-issue-123]!

      [gh-user-example]: https://github.com/example
      [gh-issue-123]: https://github.com/owner/repo/issues/123
    MD

    assert_changed expected, input
  end

  def test_handles_empty_input
    assert_unchanged ""
  end

  def test_handles_input_with_no_matches
    input = "Just some regular text"
    assert_unchanged input
  end

  def test_preserves_existing_markdown_formatting
    input = <<~MD
      # Heading

      **Bold** and *italic* text with @example mention.

      - List item
      - Another item
    MD
    expected = <<~MD
      # Heading

      **Bold** and *italic* text with [@example][gh-user-example] mention.

      - List item
      - Another item

      [gh-user-example]: https://github.com/example
    MD

    assert_changed expected, input
  end

  Dir["*.md"].each do |filename|
    testname = "test_golden_master_#{File.basename(filename, ".md").downcase}"

    define_method testname do
      input = File.read(filename)

      assert_unchanged input, message: "#{filename} should not change after linkification"
    end
  end
end
