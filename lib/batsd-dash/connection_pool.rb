module BatsdDash
  module ConnectionHelpers
    def connection_pool
      ConnectionPool.pool or render_error('Connection pool failed to connect to Batsd')
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
          @pool = EventMachine::Synchrony::ConnectionPool.new(size: settings[:pool_size]) do
            Client.new(settings[:host], settings[:port])
          end

        rescue Exception => e
          warn "Connection Pool Error: #{e.message}"

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
      def write_and_read_json(request)
        EventMachine::DefaultDeferrable.new.tap do |df|
          response = String.new
          parser = Yajl::Parser.new
          parser.on_parse_complete = Proc.new { |json| df.succeed(json) }

          begin
            write request

            # keep reading till we hit new line
            while response[-1] != "\n"
              response << read(1)
            end

            parser.parse response

          rescue Exception => e
            # TODO handle broken pipe
            #unbind if Errno::EPIPE === e

            df.fail(e)
          end
        end
      end

      def async_available_list
        write_and_read_json "available"
      end

      def async_values(statistic, range)
        write_and_read_json "values #{statistic} #{range[0]} #{range[1]}"
      end

      def unbind(reason = nil)
        super(reason)

        ConnectionPool::start_reconnect_timer
      end
    end
  end
end
