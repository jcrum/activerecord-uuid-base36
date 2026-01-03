# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "activerecord-uuid-base36"

require "minitest/autorun"
require "active_record"

# Set up in-memory SQLite database for testing
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

# Enable verbose SQL logging in tests if needed
# ActiveRecord::Base.logger = Logger.new(STDOUT)
