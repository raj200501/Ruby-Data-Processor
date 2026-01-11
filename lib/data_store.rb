require 'json'
require 'fileutils'
require 'time'

class DataStore
  def initialize(path)
    @path = path
    FileUtils.mkdir_p(File.dirname(@path))
    ensure_store
  end

  def all
    read_store.fetch('records')
  end

  def find(id)
    record = all.find { |entry| entry['id'] == id.to_i }
    record || (raise KeyError, "Record #{id} not found")
  end

  def create(attributes)
    with_lock do |store|
      record = build_record(store, attributes)
      store['records'] << record
      store['last_id'] = record['id']
      record
    end
  end

  def update(id, attributes)
    with_lock do |store|
      record = store['records'].find { |entry| entry['id'] == id.to_i }
      raise KeyError, "Record #{id} not found" unless record

      record.merge!(stringify_keys(attributes))
      record['updated_at'] = timestamp
      record
    end
  end

  def delete(id)
    with_lock do |store|
      record = store['records'].find { |entry| entry['id'] == id.to_i }
      raise KeyError, "Record #{id} not found" unless record

      store['records'].delete(record)
      record
    end
  end

  def query(filters)
    records = all
    records = records.select { |entry| entry['value'] >= filters[:min_value] } if filters[:min_value]
    records = records.select { |entry| entry['value'] <= filters[:max_value] } if filters[:max_value]
    records = records.select { |entry| entry['source'] == filters[:source] } if filters[:source]
    records = records.select { |entry| entry['name'].downcase.include?(filters[:name].downcase) } if filters[:name]
    records = records.select { |entry| Time.parse(entry['ingested_at']) >= filters[:since] } if filters[:since]

    offset = filters[:offset].to_i
    limit = filters[:limit].to_i
    records.sort_by { |entry| entry['created_at'] }.reverse.drop(offset).take(limit)
  end

  private

  def ensure_store
    return if File.exist?(@path)

    write_store('records' => [], 'last_id' => 0)
  end

  def read_store
    JSON.parse(File.read(@path))
  end

  def write_store(data)
    File.write(@path, JSON.pretty_generate(data))
  end

  def with_lock
    File.open(@path, File::RDWR | File::CREAT, 0o644) do |file|
      file.flock(File::LOCK_EX)
      file.rewind
      data = file.read
      store = data.empty? ? { 'records' => [], 'last_id' => 0 } : JSON.parse(data)
      result = yield(store)
      file.rewind
      file.truncate(0)
      file.write(JSON.pretty_generate(store))
      file.flush
      file.flock(File::LOCK_UN)
      result
    end
  end

  def build_record(store, attributes)
    timestamp = timestamp
    {
      'id' => store['last_id'].to_i + 1,
      'name' => attributes[:name],
      'value' => attributes[:value],
      'source' => attributes[:source],
      'metadata' => attributes[:metadata],
      'ingested_at' => format_time(attributes[:ingested_at]),
      'created_at' => timestamp,
      'updated_at' => timestamp
    }
  end

  def timestamp
    Time.now.utc.iso8601
  end

  def format_time(value)
    return timestamp if value.nil?
    return value.iso8601 if value.respond_to?(:iso8601)

    Time.parse(value.to_s).utc.iso8601
  rescue ArgumentError
    timestamp
  end

  def stringify_keys(attributes)
    attributes.each_with_object({}) do |(key, value), memo|
      memo[key.to_s] = value.respond_to?(:iso8601) ? value.iso8601 : value
    end
  end
end
