# frozen_string_literal: true

module ActiveRecord
  module Uuid
    module Base36
      # Automatically generates UUID defaults for primary keys
      module Model
        def load_schema!
          define_uuid_primary_key_pending_default
          super
        end

        private
          def define_uuid_primary_key_pending_default
            if uuid_primary_key?
              pending_attribute_modifications << PendingUuidDefault.new(primary_key)
            end
          rescue ActiveRecord::StatementInvalid
            # Table doesn't exist yet
          end

          def uuid_primary_key?
            table_name && primary_key && schema_cache.columns_hash(table_name)[primary_key]&.type == :uuid
          end

          unless defined?(PendingUuidDefault)
            PendingUuidDefault = Struct.new(:name) do
              def apply_to(attribute_set)
                attribute_set[name] = attribute_set[name].with_user_default(-> { ActiveRecord::Uuid::Base36::Type.generate })
              end
            end
          end
      end
    end
  end
end
