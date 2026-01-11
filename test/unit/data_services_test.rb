require_relative '../test_helper'

class DataServicesTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @path = File.join(@dir, 'data.json')
    @store = DataStore.new(@path)
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def test_ingestion_service_creates_records
    data = [
      { name: 'Temperature', value: 22.0, source: 'sensor' },
      { name: 'Humidity', value: 40.0, source: 'sensor' }
    ]

    created = DataIngestionService.new(@store, data).ingest

    assert_equal 2, created.count
    assert_equal 2, @store.all.count
  end

  def test_query_service_filters
    @store.create(name: 'Temp', value: 10.0, source: 'sensor', metadata: '{}', ingested_at: Time.now.utc)
    @store.create(name: 'Humidity', value: 20.0, source: 'sensor', metadata: '{}', ingested_at: Time.now.utc)

    results = DataQueryService.new(@store).call(min_value: 15.0)

    assert_equal 1, results.count
    assert_equal 'Humidity', results.first['name']
  end

  def test_summary_service
    @store.create(name: 'Temp', value: 10.0, source: 'sensor', metadata: '{}', ingested_at: Time.now.utc)
    @store.create(name: 'Humidity', value: 20.0, source: 'sensor', metadata: '{}', ingested_at: Time.now.utc)

    summary = DataSummaryService.new(@store).call({})

    assert_equal 2, summary[:count]
    assert_equal 15.0, summary[:average]
  end

  def test_visualization_service
    @store.create(name: 'Temp', value: 10.0, source: 'sensor', metadata: '{}', ingested_at: Time.now.utc)

    chart = DataVisualizationService.new(@store.all).generate_chart
    payload = JSON.parse(chart)

    assert payload['data']
    assert payload['summary']
  end
end
