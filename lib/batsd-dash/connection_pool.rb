module BatsdDash
  module ConnectionHelpers
    def connection_pool
      ConnectionPool.pool or render_error('Unable to connect to Batsd Server')
    end
  end

  class ConnectionPool
    class << self
      attr_accessor :settings
      attr_reader :pool

      def initialize_connection_pool
        # default settings (which are defaults from batsd itself)
        @settings ||= { host: 'localhost', port: 8127, pool_size: 4 }

        if @reconnect_timer
          @reconnect_timer.cancel
          @reconnect_timer = nil
        end

        begin
          @pool ||= EventMachine::Synchrony::ConnectionPool.new(size: settings[:pool_size]) do
            Client.new(settings[:host], settings[:port])
          end
        rescue SocketError => e
          # TODO maybe warn here or something?
          puts ENV['RACK_ENV']

        end
      end

      def close_connection_pool
        @pool.close if @pool
        @pool = nil
      end

      def start_reconnect_timer
        unless @reconnect_timer
          @reconnect_timer = EventMachine::Synchrony.add_timer(3) { initialize_connection_pool }
        end
      end
    end

    class Client < EventMachine::Synchrony::TCPSocket
      def read_json
        Yajl::Parser.parse read
      end

      def unbind
        super

        ConnectionPool::start_reconnect_timer
      end
    end
  end
end
