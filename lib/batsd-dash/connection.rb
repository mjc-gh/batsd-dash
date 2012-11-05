require 'socket'
require 'multi_json'
require 'connection_pool'

module Batsd::Dash
  class Connection
    def initialize(host, port)
      @socket = TCPSocket.new(host, port)
    end

    def available
      query 'available'
    end

    def values(statistic, range)
      query "values #{statistic} #{range[0]} #{range[1]}"
    end

    private

    def query(command)
      @socket.puts command

      MultiJson.load @socket.gets

    rescue TimeoutError => e
      puts "Connection Timeout: #{e}"

      return nil
    end
  end
end
