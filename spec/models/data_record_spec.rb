require 'rails_helper'

RSpec.describe DataRecord, type: :model do
  it "is valid with valid attributes" do
    expect(build(:data_record)).to be_valid
  end

  it "is not valid without a name" do
    expect(build(:data_record, name: nil)).to_not be_valid
  end

  it "is not valid without a value" do
    expect(build(:data_record, value: nil)).to_not be_valid
  end
end
