# frozen_string_literal: true

module ActiveRecord
  module Uuid
    module Base36
      # Table definition extensions to add uuid column type support
      module TableDefinition
        def uuid(name, **options)
          column(name, :uuid, **options)
        end
      end
    end
  end
end
