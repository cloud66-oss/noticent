# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "noticent/version"

Gem::Specification.new do |spec|
  spec.name = "noticent"
  spec.version = Noticent::VERSION
  spec.authors = ["Khash Sajadi"]
  spec.email = ["khash@cloud66.com"]

  spec.summary = "Act as Notified is a flexible framework to add notifications to a Rails application"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 5.2"
  spec.add_dependency "activesupport", ">= 5.2"
  spec.add_dependency "actionpack", ">= 5.2"

  spec.add_development_dependency "combustion", "~> 1.1"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "factory_bot", "~> 5.0"
  spec.add_development_dependency "generator_spec", "~> 0.9"
  spec.add_development_dependency "rails", "~> 5.2"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "rubocop", "~> 0.69"
  spec.add_development_dependency "rubocop-performance", "~> 1.3"
  spec.add_development_dependency "rufo", "~> 0.7"
  spec.add_development_dependency "sqlite3", "~> 1.4"
  spec.add_development_dependency "byebug", "~> 11.0"
end
