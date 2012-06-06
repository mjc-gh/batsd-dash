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
          # TODO can drop condition once sinatra-synchrony is updated
          @reconnect_timer.cancel if @reconnect_timer.respond_to?(:cancel)
          @reconnect_timer = nil
        end

        begin
          @pool ||= EventMachine::Synchrony::ConnectionPool.new(size: settings[:pool_size]) do
            Client.new(settings[:host], settings[:port])
          end

        rescue SocketError => e
          # TODO maybe warn here or something?

        end
      end

      def close_connection_pool
        @pool.close if @pool
        @pool = nil
      end

      def start_reconnect_timer
        unless @reconnect_timer
          # try to reconnect every 30 seconds
          @reconnect_timer = EventMachine::Synchrony.add_timer(30) { initialize_connection_pool }
        end
      end
    end

    class Client < EventMachine::Synchrony::TCPSocket
      # temp fix till em-synchrony gets updated in sinatra gem
      alias :send :__send__

      def write_and_read_json(data)
        EventMachine::DefaultDeferrable.new.tap do |df|
          parser = Yajl::Parser.new
          parser.on_parse_complete = Proc.new { |json| df.succeed(json) }

          write data
          parser.parse read
        end
      end

      def async_available_list
        write_and_read_json "available"
      end

      def async_values(statistic, range)
        write_and_read_json "values #{statistic} #{range[0]} #{range[1]}"
      end

      def unbind
        super

        ConnectionPool::start_reconnect_timer
      end
    end
  end
end
