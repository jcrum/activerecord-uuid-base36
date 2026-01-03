# frozen_string_literal: true

require "active_record"
require "active_support"
require "securerandom"

require_relative "activerecord/uuid/base36/version"
require_relative "activerecord/uuid/base36/type"
require_relative "activerecord/uuid/base36/model"
require_relative "activerecord/uuid/base36/mysql_adapter"
require_relative "activerecord/uuid/base36/sqlite_adapter"
require_relative "activerecord/uuid/base36/schema_dumper"
require_relative "activerecord/uuid/base36/table_definition"

module ActiveRecord
  module Uuid
    module Base36
      class Error < StandardError; end
    end
  end
end

# Register the UUID type for Trilogy (MySQL) and SQLite3 adapters
begin
  registered = ActiveRecord::Type.lookup(:uuid, adapter: :trilogy).is_a?(ActiveRecord::Uuid::Base36::Type)
rescue ArgumentError
  registered = false
end
ActiveRecord::Type.register(:uuid, ActiveRecord::Uuid::Base36::Type, adapter: :trilogy) unless registered

begin
  registered = ActiveRecord::Type.lookup(:uuid, adapter: :sqlite3).is_a?(ActiveRecord::Uuid::Base36::Type)
rescue ArgumentError
  registered = false
end
ActiveRecord::Type.register(:uuid, ActiveRecord::Uuid::Base36::Type, adapter: :sqlite3) unless registered

# Hook into ActiveRecord to install our extensions
ActiveSupport.on_load(:active_record) do
  unless ActiveRecord::Base.singleton_class.ancestors.include?(ActiveRecord::Uuid::Base36::Model)
    ActiveRecord::Base.singleton_class.prepend(ActiveRecord::Uuid::Base36::Model)
  end
  unless ActiveRecord::ConnectionAdapters::TableDefinition.ancestors.include?(ActiveRecord::Uuid::Base36::TableDefinition)
    ActiveRecord::ConnectionAdapters::TableDefinition.prepend(ActiveRecord::Uuid::Base36::TableDefinition)
  end
end

ActiveSupport.on_load(:active_record_trilogyadapter) do
  unless ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.ancestors.include?(ActiveRecord::Uuid::Base36::MysqlAdapter)
    ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.prepend(ActiveRecord::Uuid::Base36::MysqlAdapter)
  end
  unless ActiveRecord::ConnectionAdapters::MySQL::SchemaDumper.ancestors.include?(ActiveRecord::Uuid::Base36::SchemaDumper)
    ActiveRecord::ConnectionAdapters::MySQL::SchemaDumper.prepend(ActiveRecord::Uuid::Base36::SchemaDumper)
  end
end

ActiveSupport.on_load(:active_record_sqlite3adapter) do
  unless ActiveRecord::ConnectionAdapters::SQLite3Adapter.ancestors.include?(ActiveRecord::Uuid::Base36::SqliteAdapter)
    ActiveRecord::ConnectionAdapters::SQLite3Adapter.prepend(ActiveRecord::Uuid::Base36::SqliteAdapter)
  end
  unless ActiveRecord::ConnectionAdapters::SQLite3::SchemaDumper.ancestors.include?(ActiveRecord::Uuid::Base36::SchemaDumper)
    ActiveRecord::ConnectionAdapters::SQLite3::SchemaDumper.prepend(ActiveRecord::Uuid::Base36::SchemaDumper)
  end
end
