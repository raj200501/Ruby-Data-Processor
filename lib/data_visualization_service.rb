require 'ostruct'
require_relative 'data_processor/visualization'

class DataVisualizationService
  def initialize(records)
    @records = records
  end

  def generate_chart
    records = @records.map do |entry|
      OpenStruct.new(name: entry['name'], value: entry['value'])
    end
    DataProcessor::Visualization.new(records).chart_json
  end
end
