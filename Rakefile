# frozen_string_literal: true

$LOAD_PATH.unshift "lib"

require "rubygems"
require "hoe"
require "rake/clean"
require "rdoc/task"

Hoe.plugin :halostatue
Hoe.plugins.delete :debug
Hoe.plugins.delete :git
Hoe.plugins.delete :newb
Hoe.plugins.delete :publish
Hoe.plugins.delete :signing
Hoe.plugins.delete :test

hoe = Hoe.spec "hoe-halostatue" do
  developer "Austin Ziegler", "halostatue@gmail.com"

  self.trusted_release = ENV["rubygems_release_gem"] == "true"

  license "MIT"

  spec_extras[:metadata] = ->(val) {
    val.merge!({"rubygems_mfa_required" => "true"})
  }

  extra_deps << ["hoe", ">= 3.0", "< 5"]
  extra_deps << ["hoe-gemspec2", "~> 1.4"]
  extra_deps << ["hoe-markdown", "~> 1.6"]
  extra_deps << ["hoe-rubygems", "~> 1.0"]

  extra_dev_deps << ["standard", "~> 1.0"]
end

task :version do
  require "hoe/halostatue/version"
  puts Hoe::Halostatue::VERSION
end

RDoc::Task.new do
  _1.title = "Hoe::Halostatue -- Opinionated reconfiguration of Hoe"
  _1.main = "README.md"
  _1.rdoc_dir = "doc"
  _1.rdoc_files = hoe.spec.require_paths - ["Manifest.txt"] + hoe.spec.extra_rdoc_files
  _1.markup = "markdown"
end
task docs: :rerdoc
