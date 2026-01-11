require_relative '../test_helper'

class NormalizerTest < Minitest::Test
  def test_normalizes_fields
    normalizer = DataProcessor::Normalizer.new(default_source: 'sensor')
    record = normalizer.normalize('name' => ' Temp ', 'value' => '12.5')

    assert_equal 'Temp', record[:name]
    assert_equal 12.5, record[:value]
    assert_equal 'sensor', record[:source]
    assert record[:ingested_at].is_a?(Time)
  end

  def test_serializes_metadata
    normalizer = DataProcessor::Normalizer.new
    record = normalizer.normalize('name' => 'Humidity', 'value' => 10, 'metadata' => { unit: 'pct' })

    assert_equal '{"unit":"pct"}', record[:metadata]
  end
end
