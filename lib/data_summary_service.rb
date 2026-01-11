require 'ostruct'
require_relative 'data_processor/summary'
require_relative 'data_query_service'

class DataSummaryService
  def initialize(store)
    @store = store
  end

  def call(filters)
    records = DataQueryService.new(@store).call(filters)
    DataProcessor::Summary.new(records.map { |entry| OpenStruct.new(value: entry['value']) }).call
  end
end
