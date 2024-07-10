class DataTransformationService
  def initialize(data_records)
    @data_records = data_records
  end

  def transform
    @data_records.each do |record|
      record.update(value: transform_value(record.value))
    end
  end

  private

  def transform_value(value)
    value * 2 # Example transformation
  end
end
