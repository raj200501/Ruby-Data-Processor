module DataProcessor
  class Summary
    def initialize(records)
      @records = records
    end

    def call
      values = @records.map(&:value)
      {
        count: values.count,
        min: values.min,
        max: values.max,
        average: average(values)
      }
    end

    private

    def average(values)
      return nil if values.empty?

      values.sum / values.size.to_f
    end
  end
end
