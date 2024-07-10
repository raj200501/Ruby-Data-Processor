class DataIngestionService
  def initialize(data_source)
    @data_source = data_source
  end

  def ingest
    @data_source.each do |record|
      DataRecord.create!(name: record[:name], value: record[:value])
    end
  end
end
