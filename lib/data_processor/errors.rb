module DataProcessor
  class ValidationError < StandardError
    attr_reader :details

    def initialize(message = 'Validation failed', details: {})
      @details = details
      super(message)
    end
  end
end
