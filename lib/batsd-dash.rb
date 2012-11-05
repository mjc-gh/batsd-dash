require 'sinatra/base'
require 'haml'

module Batsd
  module Dash
    class << self
      attr_accessor :config
    end
  end
end

require 'batsd-dash/version'
require 'batsd-dash/connection'
require 'batsd-dash/params'
require 'batsd-dash/graph'

# require Sinatra App
require 'batsd-dash/app'
