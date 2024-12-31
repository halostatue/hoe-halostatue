# -*- encoding: utf-8 -*-
# stub: hoe-halostatue 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hoe-halostatue".freeze
  s.version = "1.0.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze]
  s.date = "2024-12-31"
  s.description = "Blah blah blah...".freeze
  s.email = ["halostatue@gmail.com".freeze]
  s.extra_rdoc_files = ["CHANGELOG.md".freeze, "Manifest.txt".freeze, "README.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "lib/hoe/halostatue.rb".freeze]
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.5.23".freeze
  s.summary = "Blah blah blah...".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<hoe>.freeze, [">= 3.0".freeze, "< 5".freeze])
  s.add_runtime_dependency(%q<hoe-doofus>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1".freeze])
  s.add_runtime_dependency(%q<hoe-git2>.freeze, ["~> 1.8".freeze])
  s.add_runtime_dependency(%q<hoe-markdown>.freeze, ["~> 1.6".freeze])
  s.add_development_dependency(%q<standard>.freeze, ["~> 1.0".freeze])
  s.add_development_dependency(%q<rdoc>.freeze, [">= 4.0".freeze, "< 7".freeze])
end
