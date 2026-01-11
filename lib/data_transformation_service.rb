require_relative 'data_processor/transformation_pipeline'

class DataTransformationService
  def initialize(store, multiplier: 2.0, offset: 0.0, clamp_min: -Float::INFINITY, clamp_max: Float::INFINITY)
    @store = store
    @pipeline = DataProcessor::TransformationPipeline.new([
      DataProcessor::ScaleStep.new(multiplier),
      DataProcessor::OffsetStep.new(offset),
      DataProcessor::ClampStep.new(min: clamp_min, max: clamp_max)
    ])
  end

  def transform
    @store.all.each do |record|
      updated_value = @pipeline.apply(record['value'])
      @store.update(record['id'], 'value' => updated_value)
    end
  end
end
