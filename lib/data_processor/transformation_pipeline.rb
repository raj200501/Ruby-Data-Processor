module DataProcessor
  class TransformationPipeline
    def initialize(steps)
      @steps = steps
    end

    def apply(value)
      @steps.reduce(value) { |current, step| step.call(current) }
    end
  end

  class ScaleStep
    def initialize(multiplier)
      @multiplier = multiplier
    end

    def call(value)
      value * @multiplier
    end
  end

  class OffsetStep
    def initialize(offset)
      @offset = offset
    end

    def call(value)
      value + @offset
    end
  end

  class ClampStep
    def initialize(min:, max:)
      @min = min
      @max = max
    end

    def call(value)
      [[value, @min].max, @max].min
    end
  end
end
