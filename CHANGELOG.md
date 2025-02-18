# hoe-halostatue Changelog

## 2.0.0 / 2025-02-19

- Directly incorporate the functionality of `hoe-doofus` and `hoe-git2` into
  `hoe-halostatue` and make it possible to disable features that would block
  automated releases via [rubygems/release-gem][trusted].

- Minor improvements to `Hoe#parse_urls` for Markdown READMEs so that wrapped
  URLs work.

- Added a `trusted_release` mode that skips the need for a `VERSION` specifier
  on the release task and ensures that features which impede automated releases
  are disabled.

- Enabled trusted publishing for this repo.

## 1.0.1 / 2024-12-31

- Birthday!

[trusted]: https://github.com/rubygems/release-gem
