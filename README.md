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

## Examples

```ruby
# In your Rakefile
Hoe.plugin :halostatue

Hoe.spec "myproj" do
  self.checklist = nil if ENV["rubygems_release_gem"] == "true"
  self.git_tag_enabled = ENV["rubygems_release_gem"] != "true"
  # ...
end
```

If this plugin cannot see that it is in a `.git` directory, `hoe-git2` derived
features will be deactivated.

## Features

Hoe::Halostatue automatically enables Hoe plugins
[`hoe-gemspec2`][hoe-gemspec2], [`hoe-markdown`][hoe-markdown], and
[`hoe-rubygems`][hoe-rubygems].

With version 2, the functionality of [`hoe-doofus`][hoe-doofus] and
[`hoe-git2`][hoe-git2] have been incorporated into Hoe::Halostatue to improve
automated release support.

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

### Automated Release Support

Certain features offered by Hoe plugins supported are useful for manual
releases, but work against automated releases (see [trusted publishing][tp]).

- `hoe-doofus` has been replaced with an internal implementation that disables
  the display if the release checklist is unset or empty.

- `hoe-git2` has been incorporated into Hoe::Halostatue, but the pieces which
  affect release can be disabled through configuration.

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

The release checklist feature has been incorporated from `hoe-doofus`.

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

### Git Integration Tasks (from `hoe-git2`)

Support for generating the CHANGELOG from the git commit messages has not been
incorporated into Hoe::Halostatue.

#### Generating the Manifest

The `Manifest.txt` required by Hoe can be generated with `rake git:manifest`.
This uses `git ls-files`, respecting the Hoe manifest sort order and excludes.

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

The tag prefix can be with `self.git_release_tag_prefix`, which defaults to `v`.

The created tag can be pushed to different remotes with `self.git_remotes`,
which defaults to `["origin"]`.

The tag will automatically be created when a release is pushed:

```console
$ rake release VERSION=1.0.0 PRERELEASE=beta.1
```

### Trusted Release

If `spec.trusted_release` is set to `true` changes will be made to the `release`
workflow. This flag is intended to be used only with a [trusted publishing][tp]
workflow. It will bypass certain protections offered by Hoe and Hoe::Halostatue:

- The version discovered by Hoe will be trusted as correct, removing the need
  for specifying the version.

- The release checklist will be skipped.

### Strict Warnings

Warnings can be made strict (an exception will be thrown) for tests by adding
the following to your test or spec helper file (`test/minitest_helper.rb` or
`spec/rspec_helper.rb` or similar):

```ruby
require "hoe/halostatue/strict_warnings"

# Optional but recommended to avoid getting warnings outside of your code.
Hoe::Halostatue::StrictWarnings.project_root = File.expand_path("../", __dir__)

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

Hoe and Git 2.37 or later.

## Installation

```console
$ gem install hoe-halostatue
```

[hoe-doofus]: https://github.com/jbarnette/hoe-doofus
[hoe-gemspec2]: https://github.com/raggi/hoe-gemspec2
[hoe-git2]: https://github.com/halostatue/hoe-git2
[hoe-markdown]: https://github.com/flavorjones/hoe-markdown
[hoe-rubygems]: https://github.com/jbarnette/hoe-rubygems
[hoe]: https://github.com/seattlerb/hoe
[rsw]: https://github.com/rails/rails/blob/66732971111a62e5940268e1daf7d413c72a234f/tools/strict_warnings.rb
[tp]: https://guides.rubygems.org/trusted-publishing/
