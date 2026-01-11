require_relative '../lib/data_store'
require_relative '../lib/ruby_data_processor/app'
require_relative '../lib/ruby_data_processor/server'

host = ENV.fetch('HOST', '127.0.0.1')
port = Integer(ENV.fetch('PORT', '3000'))
store_path = ENV.fetch('DATA_STORE_PATH', 'db/data.json')

store = DataStore.new(store_path)
app = RubyDataProcessor::App.new(store)
server = RubyDataProcessor::Server.new(host: host, port: port, app: app)

trap('INT') { server.stop }
trap('TERM') { server.stop }

server.start
