# frozen_string_literal: true

require "test_helper"

class UuidTypeTest < Minitest::Test
  def setup
    @type = ActiveRecord::Uuid::Base36::Type.new
  end

  def test_generate_produces_valid_base36_string
    uuid = ActiveRecord::Uuid::Base36::Type.generate

    assert_kind_of String, uuid
    assert_equal 25, uuid.length
    assert_match(/^[0-9a-z]{25}$/, uuid)
  end

  def test_generate_produces_unique_values
    uuid1 = ActiveRecord::Uuid::Base36::Type.generate
    uuid2 = ActiveRecord::Uuid::Base36::Type.generate

    refute_equal uuid1, uuid2
  end

  def test_serialize_deserialize_roundtrip
    original = ActiveRecord::Uuid::Base36::Type.generate
    serialized = @type.serialize(original)
    deserialized = @type.deserialize(serialized)

    assert_equal original, deserialized
  end

  def test_serialize_produces_16_byte_binary
    uuid = ActiveRecord::Uuid::Base36::Type.generate
    binary = @type.serialize(uuid)

    assert_kind_of String, binary
    assert_equal 16, binary.bytesize
  end

  def test_cast_returns_value_unchanged
    uuid = ActiveRecord::Uuid::Base36::Type.generate

    assert_equal uuid, @type.cast(uuid)
  end

  def test_serialize_nil_returns_nil
    assert_nil @type.serialize(nil)
  end

  def test_deserialize_nil_returns_nil
    assert_nil @type.deserialize(nil)
  end

  def test_normalize_base36_pads_to_25_chars
    result = ActiveRecord::Uuid::Base36::Type.normalize_base36(123)

    assert_equal 25, result.length
    assert_equal "0000000000000000000003f", result
  end
end
