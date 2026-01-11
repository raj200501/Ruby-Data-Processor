require_relative 'data_store'

class DataQueryService
  DEFAULT_LIMIT = 100
  MAX_LIMIT = 500

  def initialize(store)
    @store = store
  end

  def call(filters)
    sanitized = normalize_filters(filters)
    @store.query(sanitized)
  end

  private

  def normalize_filters(filters)
    limit = (filters[:limit] || DEFAULT_LIMIT).to_i
    {
      min_value: filters[:min_value],
      max_value: filters[:max_value],
      source: filters[:source],
      name: filters[:name],
      since: filters[:since],
      limit: [limit, MAX_LIMIT].min,
      offset: filters[:offset] || 0
    }
  end
end
