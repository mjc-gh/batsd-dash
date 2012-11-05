require 'sinatra/base'
require 'haml'

module Batsd::Dash
  class App < Sinatra::Base
    configure do
      helpers ParamsHelper, GraphHelper

      set :haml, format: :html5
      set :server, :puma

      @config = Batsd::Dash::config || { host: 'localhost', port: '8127' }
      @connection_pool = ConnectionPool.new(@config) do
        Connection.new(@config[:host], @config[:port])
      end
    end

    helpers do
      def render_error(msg)
        render_json 400, error: msg
      end

      def render_json(code = 200, json)
        halt code, String === json ? json : Yajl::Encoder.encode(json)
      end

      def connection_pool
        self.class.instance_variable_get :@connection_pool
      end
    end

    get "/" do
      haml :root
    end

    # this route renders the template (with codes for the graph)
    get "/graph", provides: :html do
      haml :view
    end

    get "/version", provides: :json do
      render_json version: BatsdDash::VERSION
    end

    get "/available", provides: :json do
      connection_pool.with do |conn|
        render_json conn.available.inspect
      end
    end

    # actual data API route
    get "/data", :provides => :json do
      statistics = parse_statistics
      range = parse_time_range

      return render_error('Invalid time range') unless range
      return render_error('Invalid metrics') if statistics.empty?

      options = { range: range.dup.map { |n| n * 1000 } }
      results = []

      statistics.each do |datatype, metrics|
        metrics.each do |metric|
          connection_pool.with do |conn|
            statistic = "#{datatype}:#{metric}"
            json = conn.values(statistic, range)

            options[:interval] ||= json['interval']
            options[:zero_fill] = !statistic.start_with?('gauges') && params[!:no_zero_fill]

            points = json[statistic] || []
            values = values_for_graph(points, options)

            results << { key: metric, type: datatype[0..-2], values: values }
          end
        end
      end

      cache_control :no_cache, :no_store
      render_json range: options[:range], interval: options[:interval], results: results
    end
  end
end

