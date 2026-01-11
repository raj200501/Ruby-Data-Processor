require 'minitest/autorun'
require 'socket'
require 'tmpdir'
require 'json'
require 'timeout'

require_relative '../lib/data_store'
require_relative '../lib/data_record_builder'
require_relative '../lib/data_ingestion_service'
require_relative '../lib/data_query_service'
require_relative '../lib/data_summary_service'
require_relative '../lib/data_transformation_service'
require_relative '../lib/data_visualization_service'
require_relative '../lib/data_processor/errors'
require_relative '../lib/data_processor/normalizer'
require_relative '../lib/data_processor/validator'
require_relative '../lib/data_processor/summary'
require_relative '../lib/data_processor/transformation_pipeline'
require_relative '../lib/data_processor/visualization'
require_relative '../lib/ruby_data_processor/app'
require_relative '../lib/ruby_data_processor/server'

module TestHelpers
  def with_server
    port = find_available_port
    Dir.mktmpdir do |dir|
      store_path = File.join(dir, 'data.json')
      store = DataStore.new(store_path)
      app = RubyDataProcessor::App.new(store)
      server = RubyDataProcessor::Server.new(host: '127.0.0.1', port: port, app: app, logger: File.open(File::NULL, 'w'))
      thread = Thread.new { server.start }

      wait_for_port(port)
      yield(port, store)
    ensure
      server.stop
      thread.kill
    end
  end

  def wait_for_port(port)
    Timeout.timeout(5) do
      loop do
        begin
          Socket.tcp('127.0.0.1', port, connect_timeout: 1) {}
          break
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          sleep 0.1
        end
      end
    end
  end

  def find_available_port
    server = TCPServer.new('127.0.0.1', 0)
    port = server.addr[1]
    server.close
    port
  end
end
