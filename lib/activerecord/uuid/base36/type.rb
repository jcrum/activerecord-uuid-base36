# frozen_string_literal: true

module ActiveRecord
  module Uuid
    module Base36
      # Custom UUID attribute type for MySQL binary storage with base36 string representation
      class Type < ::ActiveRecord::Type::Binary
        BASE36_LENGTH = 25 unless defined?(BASE36_LENGTH) # 36^25 > 2^128
        HEX_UUID_FORMAT = /\A(?:\h{8}-\h{4}-\h{4}-\h{4}-\h{12}|\h{32})\z/i unless defined?(HEX_UUID_FORMAT)
        MAX_VALUE = 2**128 unless defined?(MAX_VALUE)
        BASE36_FORMAT = /\A[0-9a-z]{1,#{BASE36_LENGTH}}\z/i unless defined?(BASE36_FORMAT)

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

          hex_string = hex(value)
          return unless hex_string

          super(hex_string.scan(/../).map(&:hex).pack("C*"))
        end

        # Accepts 1-25 base36 characters or a canonical/32-hex UUID. Returns nil for anything else
        # or for values past 128 bits, so malformed IDs match no row.
        def hex(value)
          string = value.to_s
          return string.delete("-").downcase if HEX_UUID_FORMAT.match?(string)
          return unless BASE36_FORMAT.match?(string)

          integer = string.to_i(36)
          return unless integer < MAX_VALUE

          integer.to_s(16).rjust(32, "0")
        end

        def deserialize(value)
          return unless value

          hex = value.to_s.unpack1("H*")
          self.class.normalize_base36(hex.to_i(16))
        end

        CANONICAL_FORMAT = /\A[0-9a-z]{#{BASE36_LENGTH}}\z/i unless defined?(CANONICAL_FORMAT)

        # Canonicalizes RFC/hyphenated UUIDs, 32-hex UUIDs and 25-char base36 to lowercase 25-char
        # base36. Short (1-24 char) base36 and everything else is returned unchanged, so callers
        # validating an assigned value still see malformed input; serialize pads short ids for lookups.
        def cast(value)
          return value unless value.is_a?(String)

          if HEX_UUID_FORMAT.match?(value) || CANONICAL_FORMAT.match?(value)
            hex_string = hex(value)
            return self.class.normalize_base36(hex_string.to_i(16)) if hex_string
          end

          value
        end
      end
    end
  end
end
