# frozen_string_literal: true

require_relative "lib/activerecord/uuid/base36/version"

Gem::Specification.new do |spec|
  spec.name = "activerecord-uuid-base36"
  spec.version = ActiveRecord::Uuid::Base36::VERSION
  spec.authors = ["Your Name"]
  spec.email = ["your.email@example.com"]

  spec.summary = "UUID primary keys with base36 string representation for ActiveRecord"
  spec.description = "Provides transparent UUID primary key support for MySQL and SQLite using binary(16) storage with base36 string representation. UUIDs are stored efficiently as binary(16) in the database but exposed as compact base36 strings in Ruby."
  spec.homepage = "https://github.com/yourusername/activerecord-uuid-base36"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[
    lib/**/*
    LICENSE.txt
    README.md
    CHANGELOG.md
  ]).reject { |f| File.directory?(f) }

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "activerecord", ">= 7.0"
  spec.add_dependency "activesupport", ">= 7.0"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "sqlite3", ">= 2.1"
end
