# frozen_string_literal: true

module ActiveRecord
  module Uuid
    module Base36
      # Custom UUID attribute type for MySQL binary storage with base36 string representation
      class Type < ::ActiveRecord::Type::Binary
        BASE36_LENGTH = 25 unless defined?(BASE36_LENGTH) # 36^25 > 2^128

        def self.generate
          uuid = SecureRandom.uuid_v7
          hex = uuid.delete("-")
          normalize_base36(hex.to_i(16))
        end

        def self.normalize_base36(integer)
          integer.to_s(36).rjust(BASE36_LENGTH, "0")
        end

        def serialize(value)
          return unless value

          binary = hex(value).scan(/../).map(&:hex).pack("C*")
          super(binary)
        end

        def hex(value)
          value.to_s.to_i(36).to_s(16).rjust(32, "0")
        end

        def deserialize(value)
          return unless value

          hex = value.to_s.unpack1("H*")
          self.class.normalize_base36(hex.to_i(16))
        end

        def cast(value)
          value
        end
      end
    end
  end
end
