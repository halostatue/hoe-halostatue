# -*- encoding: utf-8 -*-
# stub: hoe-halostatue 3.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hoe-halostatue".freeze
  s.version = "3.0.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/halostatue/halostatue-data/issues", "changelog_uri" => "https://github.com/halostatue/halostatue-data/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/halostatue/halostatue-data/", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/halostatue/halostatue-data/" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze]
  s.date = "1980-01-02"
  s.description = "Hoe::Halostatue is a Hoe meta-plugin that provides improved support for Markdown README files, provides features from other plugins, and enables improved support for trusted publishing.  Hoe::Halostatue 3.0 incorporates functionality derived from `hoe-gemspec2` with more support for reproducible builds and replaces `hoe-markdown` with an internal implementation.".freeze
  s.email = ["halostatue@gmail.com".freeze]
  s.extra_rdoc_files = ["CHANGELOG.md".freeze, "CODE_OF_CONDUCT.md".freeze, "CONTRIBUTING.md".freeze, "CONTRIBUTORS.md".freeze, "LICENCE.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "SECURITY.md".freeze, "licences/dco.txt".freeze]
  s.files = ["CHANGELOG.md".freeze, "CODE_OF_CONDUCT.md".freeze, "CONTRIBUTING.md".freeze, "CONTRIBUTORS.md".freeze, "LICENCE.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "SECURITY.md".freeze, "lib/hoe/halostatue.rb".freeze, "lib/hoe/halostatue/checklist.rb".freeze, "lib/hoe/halostatue/gemspec.rb".freeze, "lib/hoe/halostatue/git.rb".freeze, "lib/hoe/halostatue/markdown.rb".freeze, "lib/hoe/halostatue/markdown/linkify.rb".freeze, "lib/hoe/halostatue/strict_warnings.rb".freeze, "lib/hoe/halostatue/version.rb".freeze, "licences/dco.txt".freeze, "test/hoe/halostatue/markdown/test_linkify.rb".freeze, "test/minitest_helper.rb".freeze]
  s.homepage = "https://github.com/halostatue/halostatue-data/".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.rubygems_version = "4.0.4".freeze
  s.summary = "Hoe::Halostatue is a Hoe meta-plugin that provides improved support for Markdown README files, provides features from other plugins, and enables improved support for trusted publishing".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<hoe>.freeze, ["~> 4.0".freeze])
  s.add_runtime_dependency(%q<kramdown>.freeze, ["~> 2.3".freeze])
  s.add_runtime_dependency(%q<kramdown-parser-gfm>.freeze, ["~> 1.1".freeze])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 6.0".freeze])
  s.add_development_dependency(%q<minitest-autotest>.freeze, ["~> 1.0".freeze])
  s.add_development_dependency(%q<minitest-focus>.freeze, ["~> 1.1".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 10.0".freeze, "< 14".freeze])
  s.add_development_dependency(%q<rdoc>.freeze, [">= 6.0".freeze, "< 8".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.22".freeze])
  s.add_development_dependency(%q<simplecov-lcov>.freeze, ["~> 0.8".freeze])
  s.add_development_dependency(%q<standard>.freeze, ["~> 1.50".freeze])
end
