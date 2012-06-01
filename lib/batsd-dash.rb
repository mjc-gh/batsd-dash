require 'yajl'
require 'sinatra/base'
require 'sinatra/synchrony'
require 'sinatra/reloader' if ENV['RACK_ENV'] == 'development'

require 'helpers/input_parser'
require 'helpers/graph'

class BatsdDash < Sinatra::Base
  configure(:development) { register Sinatra::Reloader }

  configure do
    set :haml, :format => :html5

    helpers BatsdHelper::InputParser
    helpers BatsdHelper::Graph

    register Sinatra::Synchrony

    puts settings.inspect
  end

  helpers do
    # TODO move this to start up (but settings need to be available!)
    def connection_pool
      @connection_pool ||= begin
        host, port = settings.batsd_server.split(':')
        pool_size = settings.respond_to?(:pool_size) ? settings.pool_size : 4

        EventMachine::Synchrony::ConnectionPool.new(size: pool_size) do
          Class.new(EventMachine::Synchrony::TCPSocket) do
            define_method(:read_json) { |*args| Yajl::Parser.parse read }

          end.new(host, port)
        end
      end
    end

    def render_error(msg)
      status 400
      respond_with error: msg
    end

    def render_json(json)
      String === json ? json : Yajl::Encoder.encode(json)
    end
  end

  get "/" do
    haml :root
  end

  get "/available", :provides => :json do
    connection_pool.execute(true) do |conn|
      conn.write "available"
      render_json conn.read_json
    end
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

      results = { range: range.dup.map! { |n| n * 1000 }, metrics: [] }
      collect_opts = { zero_fill: !params[:no_zero_fill], range: results[:range] }

      metrics.each do |metric|
        connection_pool.execute(true) do |conn|
          conn.write "values #{datatype}:#{metric} #{range[0]} #{range[1]}"

          json = conn.read_json
          values = json["#{datatype}:#{metric}"]

          # interval is same for all
          collect_opts.merge!(interval: json['interval'] || 0) unless collect_opts.has_key?(:interval)
          # process results for graphing and add to results
          results[:metrics] << { label: metric, data: collect_for_graph(values, collect_opts) }
        end
      end

      render_json results
    end
  end
end
