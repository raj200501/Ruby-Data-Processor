require_relative '../test_helper'
require 'net/http'

class ApiTest < Minitest::Test
  include TestHelpers

  def test_health_endpoint
    with_server do |port, _store|
      response = Net::HTTP.get_response(URI("http://127.0.0.1:#{port}/health"))

      assert_equal '200', response.code
      assert_equal 'UP', JSON.parse(response.body)['status']
    end
  end

  def test_crud_flow
    with_server do |port, _store|
      uri = URI("http://127.0.0.1:#{port}/data")
      request = Net::HTTP::Post.new(uri, { 'Content-Type' => 'application/json' })
      request.body = JSON.generate(data_record: { name: 'Pressure', value: 101.2, source: 'sensor' })

      create_response = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
      assert_equal '201', create_response.code

      created = JSON.parse(create_response.body)
      get_response = Net::HTTP.get_response(URI("http://127.0.0.1:#{port}/data/#{created['id']}"))

      assert_equal '200', get_response.code
      assert_equal 'Pressure', JSON.parse(get_response.body)['name']
    end
  end

  def test_summary_endpoint
    with_server do |port, _store|
      uri = URI("http://127.0.0.1:#{port}/data")
      request = Net::HTTP::Post.new(uri, { 'Content-Type' => 'application/json' })
      request.body = JSON.generate(data_record: { name: 'Temp', value: 22.0, source: 'sensor' })

      Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }

      summary_response = Net::HTTP.get_response(URI("http://127.0.0.1:#{port}/data/summary"))
      summary = JSON.parse(summary_response.body)

      assert_equal 1, summary['count']
    end
  end
end
