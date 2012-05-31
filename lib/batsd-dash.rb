require 'yajl'
require 'sinatra/base'
require 'sinatra/synchrony'
require 'sinatra/reloader' if ENV['RACK_ENV'] == 'development'

require 'helpers/input_parser'
#require 'helpers/graph'

class BatsdDash < Sinatra::Base
  configure(:development) { register Sinatra::Reloader }

  configure do
    set :haml, :format => :html5

    helpers BatsdHelper::InputParser
    #helpers BatsdHelper::Graph

    register Sinatra::Synchrony
  end

  helpers do
    # TODO move this to start up (but settings need to be available!)
    def connection_pool
      @connection_pool ||= begin
        host, port = settings.batsd_server.split(':')
        pool_size = settings.respond_to?(:pool_size) ? settings.pool_size : 4

        EventMachine::Synchrony::ConnectionPool.new(size: pool_size) do
          Class.new(EventMachine::Synchrony::TCPSocket) do
            define_method(:read) { |*args| Yajl::Parser.parse super(*args).chomp! }

          end.new(host, port)
        end
      end
    end

    def render_error(msg)
      status 400
      respond_with error: msg
    end
  end

  get "/" do
    haml :root
  end

  %w[ counters timers gauges ].each do |datatype|
    # this route renders the template (with codes for the graph)
    get "/#{datatype}", :provides => :html do
      haml :view
    end

    # actual data API route
    get "/#{datatype}", :provides => :json do
      metrics = parse_metrics
      range = parse_time_range

      return render_error('invalid time range') unless range
      return render_error('invalid metrics') if metrics.empty?

      results = metrics.map do |metric|
        connection_pool.execute(true) do |conn|
          conn.write("values #{datatype}:#{metric} #{range[0]} #{range[1]}")

          conn.read
        end
      end

      Yajl::Encoder.encode results
    end
  end
end
