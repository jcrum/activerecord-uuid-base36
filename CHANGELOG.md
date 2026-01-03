# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2024-01-01

### Added
- Initial release
- UUID primary key support for ActiveRecord
- Base36 string representation for compact, URL-safe IDs
- MySQL (Trilogy adapter) support with binary(16) storage
- SQLite3 support with blob(16) storage
- Automatic UUID generation for primary keys
- UUID v7 support for time-ordered UUIDs
- Schema dumper integration for proper schema.rb output
- Table definition `uuid` column type support
- Automatic type registration for `:uuid` type

### Features
- `ActiveRecord::Uuid::Base36::Type` - Custom ActiveRecord type for UUID handling
- `ActiveRecord::Uuid::Base36::Type.generate` - Manual UUID generation
- Transparent serialization/deserialization between base36 strings and binary storage
- Automatic primary key default value generation
- Support for UUID foreign key columns

[Unreleased]: https://github.com/yourusername/activerecord-uuid-base36/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/activerecord-uuid-base36/releases/tag/v0.1.0