class DataVisualizationService
  def initialize(data_records)
    @data_records = data_records
  end

  def generate_chart
    # Example chart generation logic
    chart = { data: @data_records.map { |record| [record.name, record.value] } }
    chart.to_json
  end
end
