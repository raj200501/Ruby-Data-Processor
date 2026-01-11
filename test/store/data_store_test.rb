require_relative '../test_helper'

class DataStoreTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @path = File.join(@dir, 'data.json')
    @store = DataStore.new(@path)
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def test_create_and_find
    record = @store.create(name: 'Temp', value: 10.0, source: 'sensor', metadata: '{}', ingested_at: Time.now.utc)

    assert_equal 1, record['id']
    assert_equal 'Temp', @store.find(1)['name']
  end

  def test_update
    record = @store.create(name: 'Temp', value: 10.0, source: 'sensor', metadata: '{}', ingested_at: Time.now.utc)
    updated = @store.update(record['id'], value: 20.0)

    assert_equal 20.0, updated['value']
  end

  def test_delete
    record = @store.create(name: 'Temp', value: 10.0, source: 'sensor', metadata: '{}', ingested_at: Time.now.utc)
    @store.delete(record['id'])

    assert_raises(KeyError) { @store.find(record['id']) }
  end

  def test_query_filters
    @store.create(name: 'Temp', value: 10.0, source: 'sensor', metadata: '{}', ingested_at: Time.now.utc)
    @store.create(name: 'Humidity', value: 20.0, source: 'sensor', metadata: '{}', ingested_at: Time.now.utc)

    results = @store.query(min_value: 15.0, max_value: 25.0, source: 'sensor', name: 'Hum', since: Time.now.utc - 60, limit: 10, offset: 0)

    assert_equal 1, results.count
    assert_equal 'Humidity', results.first['name']
  end
end
