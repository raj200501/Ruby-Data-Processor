require_relative '../test_helper'

class SummaryTest < Minitest::Test
  def test_returns_summary
    records = [OpenStruct.new(value: 10.0), OpenStruct.new(value: 20.0)]
    summary = DataProcessor::Summary.new(records).call

    assert_equal 2, summary[:count]
    assert_equal 10.0, summary[:min]
    assert_equal 20.0, summary[:max]
    assert_equal 15.0, summary[:average]
  end
end
