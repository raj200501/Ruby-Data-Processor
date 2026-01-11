require_relative '../test_helper'

class TransformationPipelineTest < Minitest::Test
  def test_applies_steps_in_order
    pipeline = DataProcessor::TransformationPipeline.new([
      DataProcessor::ScaleStep.new(2.0),
      DataProcessor::OffsetStep.new(1.0),
      DataProcessor::ClampStep.new(min: 0.0, max: 10.0)
    ])

    assert_equal 7.0, pipeline.apply(3.0)
    assert_equal 10.0, pipeline.apply(10.0)
  end
end
