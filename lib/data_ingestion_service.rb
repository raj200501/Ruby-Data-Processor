require_relative 'data_record_builder'

class DataIngestionService
  def initialize(store, data_source, default_source: 'manual')
    @store = store
    @data_source = data_source
    @builder = DataRecordBuilder.new(default_source: default_source)
  end

  def ingest
    @data_source.map do |record|
      attributes = @builder.build_attributes(record)
      @store.create(attributes)
    end
  end
end
