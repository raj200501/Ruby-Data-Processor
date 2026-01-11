module RubyDataProcessor
  class Response
    attr_reader :status, :headers, :body

    def initialize(status:, body: '', headers: {})
      @status = status
      @headers = headers
      @body = body
    end

    def to_http
      status_line = "HTTP/1.1 #{status} #{status_message}"
      header_lines = default_headers.merge(headers).map { |key, value| "#{key}: #{value}" }
      ([status_line] + header_lines + [''] + [body]).join("\r\n")
    end

    private

    def default_headers
      {
        'Content-Type' => 'application/json',
        'Content-Length' => body.bytesize.to_s
      }
    end

    def status_message
      {
        200 => 'OK',
        201 => 'Created',
        204 => 'No Content',
        400 => 'Bad Request',
        404 => 'Not Found',
        422 => 'Unprocessable Entity',
        500 => 'Internal Server Error'
      }.fetch(status, 'OK')
    end
  end
end
