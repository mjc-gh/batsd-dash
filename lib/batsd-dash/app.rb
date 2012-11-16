require 'sinatra/base'
require 'haml'
require 'json'

module Batsd::Dash
  class App < Sinatra::Base
    configure do
      helpers ParamsHelper, GraphHelper
      set :haml, format: :html5

      config = Batsd::Dash::config || {}

      set :views, [views, config.delete(:view_path)].compact
      set :host, config.delete(:host) || 'localhost'
      set :port, config.delete(:port) || 8127

      set :view_names, [:root, :view, :missing, :layout, :loading]

      @connection_pool = ConnectionPool.new(config) do
        Connection.new(host, port)
      end
    end

    helpers do
      def find_template(views, name, engine, &block)
        path = settings.view_names.include?(name) ? views.first : views.last

        super(path, name, engine, &block)
      end

      def render_error(msg)
        render_json 400, error: msg
      end

      def render_json(code = 200, json)
        halt code, String === json ? json : JSON.dump(json)
      end

      def connection_pool
        self.class.instance_variable_get :@connection_pool
      end
    end

    get "/", provides: :html do
      haml :root
    end

    get "/graph", provides: :html do
      haml :view
    end

    get %r[/([A-Za-z0-9-_]+)$], provides: :html do
      begin
        haml params[:captures].first.to_sym, locals: { user_template: true }
      rescue Errno::ENOENT
        haml :missing
      end
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
      cache_control :no_cache, :no_store

      statistics = parse_statistics
      range = parse_time_range

      return render_error('Invalid time range') unless range
      return render_error('Invalid metrics') if statistics.empty?

      options = { range: range.dup.map { |n| n * 1000 } }
      results = []

      connection_pool.with do |conn|
        statistics.each do |datatype, metrics|
          metrics.each do |metric|
            statistic = "#{datatype}:#{metric}"
            json = conn.values(statistic, range)

            next unless json

            options[:interval] ||= json['interval']
            options[:zero_fill] = !statistic.start_with?('gauges') && params[!:no_zero_fill]

            points = json[statistic] || []
            values = values_for_graph(points, options)

            results << { key: metric, type: datatype[0..-2], values: values }
          end
        end
      end

      render_json range: options[:range], interval: options[:interval], results: results
    end
  end
end

