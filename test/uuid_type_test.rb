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

    assert_kind_of ActiveModel::Type::Binary::Data, binary
    assert_equal 16, binary.to_s.bytesize
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
    assert_equal "000000000000000000000003f", result
  end

  def test_serialize_accepts_uppercase_and_short_ids
    canonical = ActiveRecord::Uuid::Base36::Type.generate

    assert_equal @type.serialize(canonical), @type.serialize(canonical.upcase)
    assert_equal @type.serialize("000000000000000000000003f"), @type.serialize("3f")
  end

  def test_serialize_accepts_maximum_128_bit_value
    max_id = ActiveRecord::Uuid::Base36::Type.normalize_base36(2**128 - 1)

    assert_equal "\xFF".b * 16, @type.serialize(max_id).to_s
  end

  def test_serialize_rejects_malformed_ids
    ["", " abc", "abc ", "a_bc", "-1", "+1", "abc!junk", "abc\n", "a" * 26, "z" * 1_000_000].each do |value|
      assert_nil @type.serialize(value), "expected #{value[0, 30].inspect} to be rejected"
    end
  end

  def test_serialize_rejects_values_at_or_above_2_pow_128
    assert_nil @type.serialize("z" * 25)
    assert_nil @type.serialize((2**128).to_s(36))
  end

  def test_serialize_accepts_hyphenated_and_32_hex_uuids
    uuid = SecureRandom.uuid
    expected = [uuid.delete("-")].pack("H*")

    assert_equal expected, @type.serialize(uuid).to_s
    assert_equal expected, @type.serialize(uuid.upcase).to_s
    assert_equal expected, @type.serialize(uuid.delete("-")).to_s
    assert_equal uuid.delete("-").to_i(16).to_s(36).rjust(25, "0"), @type.deserialize(@type.serialize(uuid))
  end

  def test_serialize_rejects_malformed_uuids
    uuid = SecureRandom.uuid

    [uuid.sub("-", ""), uuid.tr("-", "_"), " #{uuid}", "#{uuid}\n", "#{uuid}x", uuid[1..], uuid.tr("0-9a-f", "g")].each do |value|
      assert_nil @type.serialize(value)
    end
  end
end
