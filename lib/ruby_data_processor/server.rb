require 'socket'
require 'time'
require_relative 'app'
require_relative 'request'

module RubyDataProcessor
  class Server
    def initialize(host:, port:, app:, logger: $stdout)
      @host = host
      @port = port
      @app = app
      @logger = logger
      @running = false
    end

    def start
      @server = TCPServer.new(@host, @port)
      @running = true
      log("Server listening on #{@host}:#{@port}")

      while @running
        begin
          socket = @server.accept
        rescue IOError
          break
        end

        handle_connection(socket)
      end
    ensure
      @server&.close
    end

    def stop
      @running = false
      @server&.close
    end

    private

    def handle_connection(socket)
      request = Request.parse(socket)
      if request
        response = @app.call(request)
        socket.write(response.to_http)
      end
    rescue StandardError => error
      socket.write("HTTP/1.1 500 Internal Server Error\r\nContent-Length: 0\r\n\r\n")
      log("Error: #{error.class} - #{error.message}")
    ensure
      socket.close
    end

    def log(message)
      @logger.puts("[#{Time.now.utc.iso8601}] #{message}")
    end
  end
end
