# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class RegistrationTest < Minitest::Test
  ENTRYPOINT = File.expand_path("../lib/activerecord-uuid-base36.rb", __dir__)

  def test_reloading_preserves_both_adapter_types_and_installed_hooks
    model_ancestors = ActiveRecord::Base.singleton_class.ancestors
    sqlite_ancestors = ActiveRecord::ConnectionAdapters::SQLite3Adapter.ancestors

    2.times { load ENTRYPOINT }

    [:trilogy, :sqlite3].each do |adapter|
      assert_instance_of ActiveRecord::Uuid::Base36::Type, ActiveRecord::Type.lookup(:uuid, adapter: adapter)
    end
    assert_equal model_ancestors, ActiveRecord::Base.singleton_class.ancestors
    assert_equal sqlite_ancestors, ActiveRecord::ConnectionAdapters::SQLite3Adapter.ancestors
  end

  def test_missing_adapter_type_does_not_reregister_the_other_adapter
    registrations = []
    lookup = lambda do |name, adapter:|
      raise ArgumentError, "Unknown type #{name}" if adapter == :trilogy

      ActiveRecord::Uuid::Base36::Type.new
    end
    register = ->(name, type, adapter:) { registrations << [name, type, adapter] }

    ActiveRecord::Type.stub(:lookup, lookup) do
      ActiveRecord::Type.stub(:register, register) { load ENTRYPOINT }
    end

    assert_equal [[:uuid, ActiveRecord::Uuid::Base36::Type, :trilogy]], registrations
  end
end
