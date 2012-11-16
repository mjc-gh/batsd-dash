require 'socket'
require 'connection_pool'

module Batsd::Dash
  class Connection
    attr_reader :socket

    def initialize(host, port)
      @host = host
      @port = port

      connect_socket
    end

    def available
      query 'available'
    end

    def values(statistic, range)
      query "values #{statistic} #{range[0]} #{range[1]}"
    end

    private

    def connect_socket
      @socket = TCPSocket.new(@host, @port)
    rescue Errno::ECONNREFUSED
      @socket = nil
    end

    def query(command)
      connect_socket unless socket
      return if socket.nil?

      socket.puts command

      JSON.parse socket.gets

    rescue TimeoutError => e
      return
    end
  end
end
