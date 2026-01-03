# frozen_string_literal: true

module ActiveRecord
  module Uuid
    module Base36
      # MySQL/Trilogy adapter extensions for UUID support
      module MysqlAdapter
        extend ActiveSupport::Concern

        # Override lookup_cast_type to recognize binary(16) as UUID type
        def lookup_cast_type(sql_type)
          if sql_type == "binary(16)"
            ActiveRecord::Type.lookup(:uuid, adapter: :trilogy)
          else
            super
          end
        end

        # Override fetch_type_metadata to preserve UUID type and limit
        def fetch_type_metadata(sql_type, extra = "")
          if sql_type == "binary(16)"
            simple_type = ActiveRecord::ConnectionAdapters::SqlTypeMetadata.new(
              sql_type: sql_type,
              type: :uuid,
              limit: 16
            )
            ActiveRecord::ConnectionAdapters::MySQL::TypeMetadata.new(simple_type, extra: extra)
          else
            super
          end
        end

        class_methods do
          def native_database_types
            @native_database_types_with_uuid ||= super.merge(uuid: { name: "binary", limit: 16 })
          end
        end
      end
    end
  end
end
