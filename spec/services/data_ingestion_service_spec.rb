require 'rails_helper'

RSpec.describe DataIngestionService do
  let(:data_source) { [{ name: "Temperature", value: 23.5 }, { name: "Humidity", value: 45.0 }] }

  it "ingests data correctly" do
    service = DataIngestionService.new(data_source)
    expect { service.ingest }.to change(DataRecord, :count).by(2)
  end
end
