# Findings

## 2026-10-13 Test Environment Setup
- The `Gemfile` and gemspec pinned `sqlite3 ~> 1.4`, and Active Record 8.1 needs `sqlite3 >= 2.1`. Tests could not load the adapter. Both now say `>= 2.1`.
- `bundle exec rake test` now runs: 8 runs, 2 failures. Neither is a setup problem, and neither is fixed:
  - `test_normalize_base36_pads_to_25_chars` expects a 23-character string; the code returns 25 characters, which matches the test name. The expected value in the test is wrong.
  - `test_serialize_produces_16_byte_binary` expects a `String`; on Active Record 8.1, `serialize` returns `ActiveModel::Type::Binary::Data`.
- This repo's `.gitignore` ignores `/doc/`, so this file needs `git add -f` to be committed.

## 2026-10-27 UUID registration consolidation (UUID-REF-001)

- Replaced the two adapter registration blocks with one explicit Trilogy/SQLite loop. Each iteration retains its own ArgumentError rescue and registration guard; load-hook timing and separate adapter implementations are unchanged.
- Added registration coverage for repeated loads preserving adapter lookup/hook ancestry and for one missing adapter not causing the other to be re-registered.
- Ruby syntax and diff checks pass. No test suite ran. This library does not bundle RuboCop.

## 2026-10-28 Authorized focused regression: UUID adapter registration

Explicitly approved runtime verification passed: 18 tests, 59 assertions, zero failures/errors/skips. In-memory SQLite adapter coverage and registration reload/idempotence tests pass.

Command from this project: `env -u DATABASE_URL GEM_HOME=/private/tmp/paxfish-agent-runner-gems GEM_PATH=<own temporary gem home plus shared read-only caches and Ruby 4 gem paths> BUNDLE_FROZEN=true RAILS_ENV=test /Users/jmc/.local/share/mise/installs/ruby/4.0.9/bin/ruby -rbundler/setup -Itest -e 'ARGV.each { |path| require_relative path }' test/registration_test.rb test/uuid_type_test.rb`. MCP additionally prepends that Ruby bin directory to PATH. Existing locked dependencies were installed only into the isolated temporary gem home; lockfiles and versions remain unchanged. Rails suites used their own Gemfile and inspected SQLite test configurations, prepared with `ruby -rbundler/setup -S rake app:db:prepare`; UUID uses in-memory SQLite and Logging suites use standalone controlled fixtures. Admin/OpenAPI test corrections pass syntax and target-config Rubocop.


## 2026-10-28 Focused regression verification

User-authorized focused execution results, exact scope, setup-only corrections and environment limits are recorded in the [workspace runtime report](../../../_doc/refactoring/runtime-verification.md). Earlier source-phase statements that tests were unrun are historical. This is targeted coverage, not a full-suite or Gates3/4 production-readiness claim.
