require 'json'
require_relative '../response'

module RubyDataProcessor
  module Handlers
    class HealthHandler
      def call(_request, _params = nil)
        Response.new(status: 200, body: JSON.generate(status: 'UP'))
      end
    end
  end
end
