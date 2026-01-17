# -*- encoding: utf-8 -*-
# stub: hoe-halostatue 2.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "hoe-halostatue".freeze
  s.version = "2.1.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/halostatue/halostatue-data/issues", "changelog_uri" => "https://github.com/halostatue/halostatue-data/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/halostatue/halostatue-data/", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/halostatue/halostatue-data/" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze]
  s.date = "1980-01-02"
  s.description = "Hoe::Halostatue is a Hoe meta-plugin that provides improved support for Markdown README files, provides features from other plugins, and enables improved support for trusted publishing.".freeze
  s.email = ["halostatue@gmail.com".freeze]
  s.extra_rdoc_files = ["CHANGELOG.md".freeze, "CODE_OF_CONDUCT.md".freeze, "CONTRIBUTING.md".freeze, "CONTRIBUTORS.md".freeze, "LICENCE.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "SECURITY.md".freeze, "licences/dco.txt".freeze]
  s.files = ["CHANGELOG.md".freeze, "CODE_OF_CONDUCT.md".freeze, "CONTRIBUTING.md".freeze, "CONTRIBUTORS.md".freeze, "LICENCE.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "SECURITY.md".freeze, "lib/hoe/halostatue.rb".freeze, "lib/hoe/halostatue/strict_warnings.rb".freeze, "lib/hoe/halostatue/version.rb".freeze, "licences/dco.txt".freeze]
  s.homepage = "https://github.com/halostatue/halostatue-data/".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Hoe::Halostatue is a Hoe meta-plugin that provides improved support for Markdown README files, provides features from other plugins, and enables improved support for trusted publishing.".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<hoe>.freeze, [">= 3.0".freeze, "< 5".freeze])
  s.add_runtime_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.4".freeze])
  s.add_runtime_dependency(%q<hoe-markdown>.freeze, ["~> 1.6".freeze])
  s.add_runtime_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0".freeze])
  s.add_development_dependency(%q<standard>.freeze, ["~> 1.0".freeze])
end
