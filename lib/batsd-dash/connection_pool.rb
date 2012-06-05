module BatsdDash
  module ConnectionPool
    module Helpers
      def connection_pool
        self.class.connection_pool or render_error('Unable to connect to Batsd Server')
      end
    end

    def self.registered(app)
      app.helpers ConnectionPool::Helpers
    end

    attr_reader :connection_pool

    def connection_settings(host, port, size = 4)
      @connection_settings = { host: host, port: port, pool_size: size }
    end

    def initialize_connection_pool
      # default settings (which are defaults from batsd itself)
      @connection_settings ||= { host: 'localhost', port: 8127, pool_size: 4}

      begin
        @connection_pool ||= EventMachine::Synchrony::ConnectionPool.new(size: @connection_settings[:pool_size]) do
          Client.new(@connection_settings[:host], @connection_settings[:port])
        end
      rescue SocketError => e
        # failed to connect -- setup reconnect timer

      end
    end

    def close_connection_pool
      @connection_pool.close if @connection_pool
      @connection_pool = nil
    end

    class Client < EventMachine::Synchrony::TCPSocket
      def read_json
        Yajl::Parser.parse read
      end
    end
  end
end
