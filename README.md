# Hoe::Halostatue Meta-Plugin

- home :: <https://github.com/halostatue/halostatue-data/>
- issues :: <https://github.com/halostatue/halostatue-data/issues>
- code :: <https://github.com/halostatue/halostatue-data/>
- changelog ::
  <https://github.com/halostatue/halostatue-data/blob/main/CHANGELOG.md>

## Description

Hoe::Halostatue is a [Hoe][hoe] meta-plugin that provides improved support for
Markdown README files, provides features from other plugins, and enables
improved support for [trusted publishing][tp].

Hoe::Halostatue 3.0 incorporates functionality derived from
[`hoe-gemspec2`][hgs2] with more support for [reproducible builds][rb] and
replaces [`hoe-markdown`][hmd] with an internal implementation.

## Examples

```ruby
# In your Rakefile
Hoe.plugin :halostatue

Hoe.spec "myproj" do
  self.checklist = nil if ENV["rubygems_release_gem"] == "true"
  self.git_tag_enabled = ENV["rubygems_release_gem"] != "true"
  self.reproducible_gemspec = true
  # ...
end
```

## Features

- Improved Markdown support through functionality derived from
  [`hoe-markdown`][hmd].

- Improved manual release support by adding a display checklist as a reminder of
  tasks frequently forgotten, inspired by [`hoe-doofus`][hd].

- Improved support of automated releases and reproducible builds by
  incorporating modified versions of [`hoe-git2`][hg2] and
  [`hoe-gemspec2`][hgs2].

### Improved Metadata URL Parsing

Hoe::Halostatue provides an improved implementation for `Hoe#parse_urls`. The
expected format is more or less the same, but accepts any left-aligned unordered
Markdown list (beginning with `-`, `+`, or `*`) and handles lists that wrap
lines (such as the `changelog` entry at the top of this file).

It is more strict than the default `Hoe#parse_urls` because it only accepts the
known aliases for the various RubyGems URI meta keys.

| RubyGems URI Meta Key | Alias                                     |
| --------------------- | ----------------------------------------- |
| `documentation_uri`   | `doco`, `docs`, `documentation`           |
| `bug_tracker_uri`     | `bugs`, `issues`, `tickets`               |
| `changelog_uri`       | `clog`, `changelog`, `changes`, `history` |
| `homepage_uri`        | `home`, `homepage`                        |
| `wiki_uri`            | `wiki`                                    |
| `mailing_list_uri`    | `mail`                                    |

### Markdown Support

Hoe::Halostatue used code originally developed in [`hoe-markdown`][hmd].

#### History and README Files

Hoe was originally written before Markdown support was pervasive in software
forges and before RubyDocs supported Markdown rendering. It assumes that your
README is `README.txt` and that your changelog file is `History.txt`.

As a maintainer, you need to opt out of this — unless you use `hoe-markdown` or
Hoe::Halostatue, which allows you to remove this modification from your
`Rakefile`:

```ruby
Hoe.spec "projectname" do
  # ...
  self.history_file = "CHANGELOG.md"
  self.readme_file = "README.md"
  # ...
end
```

Specifically, Hoe::Halostatue will use `README.md` if it exists for
`spec.readme_file`, and will use case-insensitive matching against
`CHANGELOG.md` or `HISTORY.md` for your history file. `CHANGELOG` is preferred
over `HISTORY`, and exact matches are preferred over case-insensitive matches.

```diff
 Hoe.spec "projectname" do
   # ...
-  self.history_file = "CHANGELOG.md"
-  self.readme_file = "README.md"
   # ...
 end
```

#### Automatically Link to GitHub

A rake task `markdown:linkify` is created that automatically converts GitHub
references to hyperlinks in your Markdown files and bare hyperlinks to readable
links.

| Input                                           | Output                                                            |
| ----------------------------------------------- | ----------------------------------------------------------------- |
| `@username`                                     | `[@username](https://github.com/username)`                        |
| `https://github.com/username`                   | `[@username](https://github.com/username)`                        |
| `https://github.com/owner/repo`                 | `[owner/repo](https://github.com/owner/repo)`                     |
| `owner/repo#123`                                | `[owner/repo#123](https://github.com/owner/repo/issues/123)`      |
| `https://github.com/owner/repo/issues/123`      | `[owner/repo#123](https://github.com/owner/repo/issues/123)`      |
| `https://github.com/owner/repo/pull/123`        | `[owner/repo#123](https://github.com/owner/repo/pull/123)`        |
| `https://github.com/owner/repo/discussions/123` | `[owner/repo#123](https://github.com/owner/repo/discussions/123)` |

Issue, pull request, and discussion links to comments will be rendered with
`(comment)` appended:

| Input                                                                 | Output                                                                                            |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `https://github.com/owner/repo/issues/123#issuecomment-987`           | `[owner/repo#123 (comment)](https://github.com/owner/repo/issues/123#issuecomment-987)`           |
| `https://github.com/owner/repo/pull/123#issuecomment-987`             | `[owner/repo#123 (comment)](https://github.com/owner/repo/pull/123#issuecomment-987)`             |
| `https://github.com/owner/repo/discussions/123#discussioncomment-987` | `[owner/repo#123 (comment)](https://github.com/owner/repo/discussions/123#discussioncomment-987)` |

Query parameters and fragments are preserved in the link URL:

| Input                                              | Output                                                               |
| -------------------------------------------------- | -------------------------------------------------------------------- |
| `https://github.com/owner/repo/issues/123?foo=bar` | `[owner/repo#123](https://github.com/owner/repo/issues/123?foo=bar)` |
| `https://github.com/owner/repo/issues/123#heading` | `[owner/repo#123](https://github.com/owner/repo/issues/123#heading)` |

> [!NOTE]
>
> If `spec.metadata["bug_tracker_uri"]` points to a GitHub repo, link labels to
> that repo are shortened:
>
> | Input                                                       | Output Link Text           |
> | ----------------------------------------------------------- | -------------------------- |
> | `https://github.com/your/repo/issues/123`                   | `#123`                     |
> | `https://github.com/your/repo/issues/123#issuecomment-789`  | `#123 (comment)`           |
> | `https://github.com/other/repo/issues/456`                  | `other/repo#456`           |
> | `https://github.com/other/repo/issues/456#issuecomment-987` | `other/repo#456 (comment)` |

> [!IMPORTANT]
>
> Link transformation will be skipped in the following cases:
>
> - Patterns in code blocks (`` ``` ``) or code spans (`` ` ``)
> - Patterns already in links: `[#123](url)` or `<https://...>`
> - Email addresses: `user@example.com`
> - Mastodon handles: `@user@instance.com`
> - Invalid usernames[^2]: `@-invalid`, `@foo--bar`

The rest of your Markdown documentation should be unmodified.

##### Example

If your README sets the `spec.metadata["bug_tracker_uri"]` to
`https://github.com/cogswellcogs/sprocketkiller/issues`[^3], when you
`markdown:linkify` against the CHANGELOG that looks like this:

```markdown
# Changelog

## v1.0.0

Bugfix: Frobnicate the transmogrifier. #123 Thanks, @hobbes!

Feature: Finagle the sprocket. See
https://github.com/cogswellcogs/sprocketkiller/pull/456#issuecomment-987
```

it is transformed to:

```markdown
# Changelog

## v1.0.0

Bugfix: Frobnicate the transmogrifier. [#123][gh-issue-123] Thanks,
[@hobbes][gh-user-hobbes]!

Feature: Finagle the sprocket. See [#456 (comment)][gh-issue-456-987]

[gh-user-hobbes]: https://github.com/hobbes
[gh-issue-123]: https://github.com/cogswellcogs/sprocketkiller/issues/123
[gh-issue-456-987]: https://github.com/cogswellcogs/sprocketkiller/pull/456#issuecomment-987
```

### Link Generation Options

All Markdown files in your `Manifest.txt` will be processed by
`markdown:linkify`, unless modified by `spec.markdown_linkify_files`.

- `spec.markdown_linkify_files` (default `[:default]`): The list of files to
  process. If the list value contains `:default`, then all `.md` files in the
  manifest will be included.

  Files may be excluded from the list by adding `{exclude: patterns}` to the
  list, where `patterns` is a glob pattern string, a regular expression, or a
  list of glob pattern strings or regular expressions.

  ```ruby
  self.markdown_linkify_files << {exclude: "licences/*"}
  ```

  This will exclude any link found in files in the `licenses/` directory.

- `spec.markdown_linkify_style` (default `:reference`): The style for producing
  links. Valid values are:

  - `:reference`, which will produce named reference links (e.g.,
    `[#123][gh-issue-123]`)
  - `:inline`, which produces inline links (e.g., `[#123](https://…)`)

  Existing links _will not be modified_.

  When using reference links, existing reference link definitions will not be
  moved, but new definitions will be appended to the end of the file.

- `spec.markdown_linkify_uri_prefixes` (default `nil`): Controls whether
  shortened URIs for the current repository have prefixes added to them. This is
  either falsy (no prefixes added), `true` default prefixes are added, or a map
  with one or more type (`issue`, `pull`, `discussion`) and the prefix to be
  applied. The default prefixes (when `true`) are
  `{issue: 'issue', pull: 'pull', discussion: 'discussion'}`.

  Examples (assuming `true`):

  ```markdown
  [issue #123](https://github.com/cogswellcogs/sprocketkiller/issues/123
  [pull #246](https://github.com/cogswellcogs/sprocketkiller/pull/246)
  [discussion #369](https://github.com/cogswellcogs/sprocketkiller/discussions/369)
  ```

### Automated Release Support

Certain features offered by Hoe plugins are useful for manual releases but work
against automated releases (see [trusted publishing][tp]).

- The checklist feature will be disabled when trusted publishing is turned on or
  the checklist is unset or empty.

- Automatic release tagging is enabled by default, but may be disabled when
  using release triggers like [release-please][rp].

In the example below, the release checklist and Git tag creation will be
disabled if `$rubygems_release_gem` is `true`.

```ruby
Hoe.plugin :halostatue

Hoe.spec "myproj" do
  self.checklist = nil if ENV["rubygems_release_gem"] == "true"
  self.git_tag_enabled = ENV["rubygems_release_gem"] != "true"
  # ...
end
```

### Release Checklist (from `hoe-doofus`)

The release checklist feature has been incorporated from `hoe-doofus`, described
as:

> A Hoe plugin that helps me (and you, maybe?) keep from messing up gem
> releases. It shows a configurable checklist when `rake release` is run, and
> provides a chance to abort if anything's been forgotten.

The current checklist can be seen by running `rake checklist` and the checklist
may be set by using `self.checklist << "new item"` in your spec. If the
checklist is `nil` or empty, the checklist prompt will not be displayed.

```ruby
Hoe.plugin :halostatue

Hoe.spec "myproj" do
  if ENV["rubygems_release_gem"] == "true"
    self.checklist = nil
  else
    checklist << "Given the release a snappy name"
  end
end
```

The checklist is automatically disabled when executing a trusted publishing
workflow.

### Git Integration Tasks (from `hoe-git2`)

If Hoe::Halostatue cannot see that it is in a `.git` repository, these features
will be deactivated.

#### Generating the Manifest

The `Manifest.txt` required by Hoe can be generated with `rake git:manifest`.
This uses `git ls-files`, respecting the Hoe manifest sort order and `.hoerc`
excludes.

#### Tagging and Sanity Checking a Release

A release will be aborted if your Git index is dirty or there are untracked
files present. After the release is published, a Git tag will be created and
pushed to your repo remotes. Both `$PRERELEASE` and `$PRE` tags are supported,
with `$PRERELEASE` taking precedence over `$PRE`, just as with Hoe itself.

In the following example with no other configuration, a `v1.0.0.beta.1` tag will
be created and pushed to the `origin` remote.

```console
$ rake git:tag VERSION=1.0.0 PRERELEASE=beta.1
```

The tag prefix can be set with `self.git_release_tag_prefix`, which defaults to
`v`.

The created tag can be pushed to different remotes with `self.git_remotes`,
which defaults to `["origin"]`.

The tag will automatically be created when a release is pushed:

```console
$ rake release VERSION=1.0.0 PRERELEASE=beta.1
```

#### Features Not Included

Support for generating the CHANGELOG from the git commit messages has not been
incorporated into Hoe::Halostatue. There are better tools for producing a
changelog automatically (such as [changie][cg] or [cocogitto][cc]), and I prefer
to manage my changelogs by hand.

Listing the applied tags is better done with `git tag`.

### Regenerating the Gem Spec (from `hoe-gemspec2`)

The ability to regenerate the gem specification using `rake gemspec` has been
added from `hoe-gemspec2`. This variant adds support for reproducible builds to
the spec generation.

Note that `rake gemspec:full` has been removed; there is no support for RubyGems
`signing_key` and `cert_chain`.

#### Reproducible Build Support

> [!NOTE]
>
> Documentation on reproducible builds in RubyGems is fairly thin, but this
> amounts to having a fixed date set for the specification `date`, which is also
> used to ensure that all files have the same date.

Reproducible builds are primarily performed by setting the value of
`$SOURCE_DATE_EPOCH`. If unset, RubyGems will use a fixed date (1980-01-02), but
only when building the gem.

The Hoe::Halostatue implementation of the `gemspec` task will set the generated
specification date and `$SOURCE_DATE_EPOCH` for proper handling by the RubyGems
build process.

> [!IMPORTANT]
>
> Most projects will use the default reproducible builds behaviour and should
> not have `$SOURCE_DATE_EPOCH` set when publishing releases (either manually or
> in CI environments).

For other cases, `$SOURCE_DATE_EPOCH` is used if it is set, or behaviour is
controlled by the `spec.reproducible_gemspec` option.

- `:default` / `true`: uses the default RubyGems behaviour, setting the date to
  `1980-01-02`

- `:current`: uses the date in the current gem `gemspec` file, or falls back to
  the default RubyGems behaviour

- `false`: disables reproducible builds as much as possible

- Integer or String values: parsed as the integer source date epoch as seconds
  from the Unix epoch

The default `spec.reproducible_gemspec` value is `:default`.

### Trusted Release

> [!IMPORTANT]
>
> Trusted releases should only be enabled when using a [trusted publishing][tp]
> workflow. It is strongly recommended that all gem releases be performed with
> such a workflow.

If `spec.trusted_release` is set to `true` changes will be made to the `release`
workflow. It will bypass certain manual release protections offered by Hoe and
Hoe::Halostatue:

- The version discovered by Hoe will be trusted as correct, removing the need
  for specifying the version.

- The release checklist will be skipped.

### Strict Deprecation Warnings

Deprecation warnings signal code that will break in future Ruby or gem versions.
Making warnings strict during tests catches these issues early, before they
reach production or complicate upgrades.

Warnings can be made strict (an exception will be thrown) for tests by adding
the following to your test or spec helper file (`test/minitest_helper.rb` or
`spec/rspec_helper.rb` or similar):

```ruby
require "hoe/halostatue/strict_warnings"

# Optional but recommended to avoid getting warnings outside of your code.
Hoe::Halostatue::StrictWarnings.project_root = File.expand_path(__dir__, "../")

# Optional regex patterns to suppress. Suppressed messages will not be printed
# to standard error. The patterns provided will be converted to a single regex
# on assignment.
Hoe::Halostatue::StrictWarnings.suppressed = [
  /circular require considered harmful/
]

# Optional regex patterns to allow. Allowed messages will be printed to
# standard error, but will not raise an exception. The patterns provided will
# be converted to a single regex on assignment.
Hoe::Halostatue::StrictWarnings.allowed = [
  /oval require considered harmful/
]
```

This is based on [RailsStrictWarnings][rsw].

## Dependencies

Hoe 4 and Git 2.37 or later.

## Installation

```console
$ gem install hoe-halostatue
```

[^1]: Also includes discussions and pull requests

[^2]: GitHub username may only contain alphanumeric characters or hyphens, may
    not have multiple consecutive hyphens, may not begin or end with a hyphen,
    and may have at most 39 characters.

[^3]: ```markdown
    - bugs: <https://github.com/cogswellcogs/sprocketkiller/issues
    ```

[cc]: https://docs.cocogitto.io
[cg]: https://changie.dev
[hd]: https://github.com/jbarnette/hoe-doofus
[hg2]: https://github.com/halostatue/hoe-git2
[hgs2]: https://github.com/raggi/hoe-gemspec2
[hmd]: https://github.com/flavorjones/hoe-markdown
[hoe]: https://github.com/seattlerb/hoe
[rb]: https://reproducible-builds.org/
[rp]: https://github.com/googleapis/release-please
[rsw]: https://github.com/rails/rails/blob/66732971111a62e5940268e1daf7d413c72a234f/tools/strict_warnings.rb
[tp]: https://guides.rubygems.org/trusted-publishing/
[lgo]: #link-generation-options
