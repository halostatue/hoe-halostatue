# hoe-halostatue Changelog

## 2.1.1 / 2025-06-26

- Actually include strict warnings support files.

## 2.1.0 / 2025-06-18

- Add support for enabling "strict warnings" similar to
  [RailsStrictWarnings][rsw].

- Updated several governance documents.

- Improved summary and link description cleaning.

## 2.0.1 / 2025-06-12

- Update minimum version of hoe-gemspec2.

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

[rsw]: https://github.com/rails/rails/blob/66732971111a62e5940268e1daf7d413c72a234f/tools/strict_warnings.rb
[trusted]: https://github.com/rubygems/release-gem
