require 'json'
require 'time'
require_relative '../../data_store'
require_relative '../../data_ingestion_service'
require_relative '../../data_query_service'
require_relative '../../data_record_builder'
require_relative '../../data_summary_service'
require_relative '../../data_visualization_service'
require_relative '../response'

module RubyDataProcessor
  module Handlers
    class DataHandler
      def initialize(store)
        @store = store
        @builder = DataRecordBuilder.new
      end

      def index(request, _params)
        filters = extract_filters(request)
        records = DataQueryService.new(@store).call(filters)
        Response.new(status: 200, body: JSON.generate(records))
      end

      def show(_request, params)
        record = @store.find(params[:id])
        Response.new(status: 200, body: JSON.generate(record))
      rescue KeyError => error
        not_found(error.message)
      end

      def create(request, _params)
        payload = request.json
        return bad_request('Invalid JSON payload') unless payload

        data = payload['data_record']
        return bad_request('Missing data_record payload') unless data

        attributes = @builder.build_attributes(data)
        record = @store.create(attributes)
        Response.new(status: 201, body: JSON.generate(record))
      rescue DataProcessor::ValidationError => error
        validation_error(error)
      end

      def update(request, params)
        payload = request.json
        return bad_request('Invalid JSON payload') unless payload

        data = payload['data_record']
        return bad_request('Missing data_record payload') unless data

        attributes = @builder.build_attributes(data)
        record = @store.update(params[:id], attributes)
        Response.new(status: 200, body: JSON.generate(record))
      rescue KeyError => error
        not_found(error.message)
      rescue DataProcessor::ValidationError => error
        validation_error(error)
      end

      def destroy(_request, params)
        @store.delete(params[:id])
        Response.new(status: 204, body: '')
      rescue KeyError => error
        not_found(error.message)
      end

      def bulk(request, _params)
        payload = request.json
        return bad_request('Invalid JSON payload') unless payload

        data = payload['data']
        return bad_request('Missing data payload') unless data

        records = DataIngestionService.new(@store, data).ingest
        Response.new(status: 201, body: JSON.generate(created: records.count))
      rescue DataProcessor::ValidationError => error
        validation_error(error)
      end

      def summary(request, _params)
        filters = extract_filters(request)
        summary = DataSummaryService.new(@store).call(filters)
        Response.new(status: 200, body: JSON.generate(summary))
      end

      private

      def extract_filters(request)
        {
          min_value: parse_float(request.query_params['min_value']),
          max_value: parse_float(request.query_params['max_value']),
          source: request.query_params['source'],
          name: request.query_params['name'],
          since: parse_time(request.query_params['since']),
          limit: parse_integer(request.query_params['limit'], default: DataQueryService::DEFAULT_LIMIT),
          offset: parse_integer(request.query_params['offset'], default: 0)
        }
      end

      def parse_float(value)
        return nil if value.nil? || value.to_s.strip.empty?

        Float(value)
      rescue ArgumentError
        nil
      end

      def parse_time(value)
        return nil if value.nil? || value.to_s.strip.empty?

        Time.parse(value)
      rescue ArgumentError
        nil
      end

      def parse_integer(value, default:)
        return default if value.nil? || value.to_s.strip.empty?

        Integer(value)
      rescue ArgumentError
        default
      end

      def validation_error(error)
        Response.new(status: 422, body: JSON.generate(error: 'validation_error', message: error.message, details: error.details))
      end

      def bad_request(message)
        Response.new(status: 400, body: JSON.generate(error: 'bad_request', message: message))
      end

      def not_found(message)
        Response.new(status: 404, body: JSON.generate(error: 'not_found', message: message))
      end
    end
  end
end
