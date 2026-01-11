module DataProcessor
  class Validator
    def validate!(normalized)
      errors = {}
      errors[:name] = 'is required' if normalized[:name].to_s.strip.empty?
      errors[:value] = 'must be numeric' unless normalized[:value].is_a?(Numeric)
      errors[:source] = 'is required' if normalized[:source].to_s.strip.empty?

      if errors.any?
        raise ValidationError.new('Record validation failed', details: errors)
      end

      normalized
    end
  end
end
