require 'json'
require 'time'

module DataProcessor
  class Visualization
    def initialize(records)
      @records = records
    end

    def chart_json
      {
        generated_at: Time.now.utc.iso8601,
        data: @records.map { |record| [record.name, record.value] },
        summary: Summary.new(@records).call
      }.to_json
    end
  end
end
