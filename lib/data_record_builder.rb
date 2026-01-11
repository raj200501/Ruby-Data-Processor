require_relative 'data_processor/normalizer'
require_relative 'data_processor/validator'

class DataRecordBuilder
  def initialize(default_source: 'manual')
    @normalizer = DataProcessor::Normalizer.new(default_source: default_source)
    @validator = DataProcessor::Validator.new
  end

  def build_attributes(attributes)
    normalized = @normalizer.normalize(attributes)
    @validator.validate!(normalized)
    normalized
  end
end
