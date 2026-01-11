require 'json'
require 'uri'

module RubyDataProcessor
  class Request
    attr_reader :method, :path, :query_params, :headers, :body, :json

    def initialize(method:, path:, query_params:, headers:, body:)
      @method = method
      @path = path
      @query_params = query_params
      @headers = headers
      @body = body
      @json = parse_json
    end

    def self.parse(socket)
      request_line = socket.gets&.strip
      return nil unless request_line

      method, full_path, _http_version = request_line.split(' ')
      headers = read_headers(socket)
      body = read_body(socket, headers)
      path, query_params = parse_path(full_path)

      new(method: method, path: path, query_params: query_params, headers: headers, body: body)
    end

    private

    def self.read_headers(socket)
      headers = {}
      loop do
        line = socket.gets
        break if line.nil? || line == "\r\n"
        key, value = line.split(':', 2)
        headers[key.downcase] = value.strip if key && value
      end
      headers
    end

    def self.read_body(socket, headers)
      length = headers['content-length'].to_i
      return '' if length.zero?

      socket.read(length)
    end

    def self.parse_path(full_path)
      uri = URI.parse(full_path)
      query_params = URI.decode_www_form(uri.query.to_s).to_h
      [uri.path, query_params]
    end

    def parse_json
      return nil if body.to_s.strip.empty?
      return nil unless headers['content-type']&.include?('application/json')

      JSON.parse(body)
    rescue JSON::ParserError
      nil
    end
  end
end
