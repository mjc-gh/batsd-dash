require 'socket'
require 'connection_pool'

module Batsd::Dash
  class Connection
    class SocketError < Exception; end

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

    def reset_socket
      @socket = nil
    end

    def connect_socket
      @socket = TCPSocket.new(@host, @port)

    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
      reset_socket
    end

    def query(command, attempts = 0)
      connect_socket unless socket

      raise SocketError.new('Socket not Connected') if socket.nil?

      socket.puts command
      JSON.parse socket.gets

    rescue Errno::EPIPE
      reset_socket

      if attempts < 5
        query command, attempts + 1
      end
    end
  end
end
