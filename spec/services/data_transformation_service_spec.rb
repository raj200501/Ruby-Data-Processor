require 'rails_helper'

RSpec.describe DataTransformationService do
  let!(:data_records) { create_list(:data_record, 2, value: 10.0) }

  it "transforms data correctly" do
    service = DataTransformationService.new(data_records)
    service.transform
    data_records.each do |record|
      expect(record.reload.value).to eq(20.0)
    end
  end
end
