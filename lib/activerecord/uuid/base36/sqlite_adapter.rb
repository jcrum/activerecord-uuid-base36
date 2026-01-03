# frozen_string_literal: true

module ActiveRecord
  module Uuid
    module Base36
      # SQLite3 adapter extensions for UUID support
      module SqliteAdapter
        extend ActiveSupport::Concern

        # Override lookup_cast_type to recognize BLOB as UUID type
        def lookup_cast_type(sql_type)
          if sql_type == "blob(16)"
            ActiveRecord::Type.lookup(:uuid, adapter: :sqlite3)
          else
            super
          end
        end

        # Override fetch_type_metadata to preserve UUID type and limit
        def fetch_type_metadata(sql_type)
          if sql_type == "blob(16)"
            ActiveRecord::ConnectionAdapters::SqlTypeMetadata.new(
              sql_type: sql_type,
              type: :uuid,
              limit: 16
            )
          else
            super
          end
        end

        class_methods do
          def native_database_types
            @native_database_types_with_uuid ||= super.merge(uuid: { name: "blob", limit: 16 })
          end
        end
      end
    end
  end
end
