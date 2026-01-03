# frozen_string_literal: true

module ActiveRecord
  module Uuid
    module Base36
      # Schema dumper extensions to map binary(16) and blob(16) columns to :uuid type
      module SchemaDumper
        # Map binary(16) and blob(16) columns to :uuid type in schema.rb
        def schema_type(column)
          if column.sql_type == "binary(16)" || column.sql_type == "blob(16)"
            :uuid
          else
            super
          end
        end
      end
    end
  end
end
