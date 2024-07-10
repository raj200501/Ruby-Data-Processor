require 'rails_helper'

RSpec.describe DataVisualizationService do
  let!(:data_records) { create_list(:data_record, 2, value: 10.0) }

  it "generates chart data correctly" do
    service = DataVisualizationService.new(data_records)
    chart_data = service.generate_chart
    expect(chart_data).to include('"data":[["Temperature",10.0],["Humidity",10.0]]')
  end
end
