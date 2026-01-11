#!/usr/bin/env ruby
require 'socket'

port = Integer(ARGV.fetch(0))
timeout = Integer(ARGV.fetch(1, 20))
start = Time.now

loop do
  begin
    Socket.tcp('127.0.0.1', port, connect_timeout: 1) {}
    exit 0
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
    if Time.now - start > timeout
      warn "Timed out waiting for port #{port}"
      exit 1
    end
    sleep 0.5
  end
end
