require 'json'
require 'time'

module DataProcessor
  class Normalizer
    def initialize(default_source: 'manual', clock: Time)
      @default_source = default_source
      @clock = clock
    end

    def normalize(raw_record)
      data = raw_record.transform_keys(&:to_s)
      {
        name: normalize_name(data['name']),
        value: normalize_value(data['value']),
        source: normalize_source(data['source']),
        metadata: normalize_metadata(data['metadata']),
        ingested_at: normalize_time(data['ingested_at'])
      }
    end

    private

    def normalize_name(name)
      name.to_s.strip
    end

    def normalize_value(value)
      return nil if value.nil?
      return value if value.is_a?(Numeric)

      Float(value)
    rescue ArgumentError, TypeError
      value
    end

    def normalize_source(source)
      (source || @default_source).to_s.strip
    end

    def normalize_metadata(metadata)
      return nil if metadata.nil?
      return metadata.to_json if metadata.is_a?(Hash)

      metadata.to_s
    end

    def normalize_time(timestamp)
      return @clock.now if timestamp.nil?
      return timestamp if timestamp.is_a?(Time)

      Time.parse(timestamp.to_s)
    rescue ArgumentError, TypeError
      @clock.now
    end
  end
end
