require 'json'
require_relative 'request'
require_relative 'response'
require_relative 'router'
require_relative 'handlers/health_handler'
require_relative 'handlers/data_handler'

module RubyDataProcessor
  class App
    def initialize(store)
      @router = Router.new
      data_handler = Handlers::DataHandler.new(store)

      @router.add('GET', '/health', Handlers::HealthHandler.new.method(:call))
      @router.add('GET', '/data', data_handler.method(:index))
      @router.add('POST', '/data', data_handler.method(:create))
      @router.add('POST', '/data/bulk', data_handler.method(:bulk))
      @router.add('GET', '/data/summary', data_handler.method(:summary))
      @router.add('GET', '/data/:id', data_handler.method(:show))
      @router.add('PUT', '/data/:id', data_handler.method(:update))
      @router.add('DELETE', '/data/:id', data_handler.method(:destroy))
    end

    def call(request)
      response = @router.route(request)
      response || Response.new(status: 404, body: JSON.generate(error: 'not_found', message: 'Route not found'))
    rescue StandardError => error
      Response.new(status: 500, body: JSON.generate(error: 'internal_error', message: error.message))
    end
  end
end
