require_relative '../test_helper'

class ValidatorTest < Minitest::Test
  def test_accepts_valid_record
    validator = DataProcessor::Validator.new
    record = { name: 'Temperature', value: 10.0, source: 'sensor' }

    assert_equal record, validator.validate!(record)
  end

  def test_rejects_invalid_record
    validator = DataProcessor::Validator.new

    error = assert_raises(DataProcessor::ValidationError) do
      validator.validate!(name: '', value: 'bad', source: '')
    end

    assert_includes error.details.keys, :name
    assert_includes error.details.keys, :value
    assert_includes error.details.keys, :source
  end
end
