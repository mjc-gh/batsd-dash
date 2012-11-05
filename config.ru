# see https://github.com/mikeycgto/batsd-dash for details
ENV['RACK_ENV'] = 'development'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'batsd-dash'

# define some setting
Batsd::Dash.config = {
  host: 'localhost', port: 8127, size: 5, timeout: 5
}

# define list of metrics
run Batsd::Dash::App
