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
