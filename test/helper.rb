require 'sinatra/test_helpers'
require 'minitest/autorun'
require 'rack/test'

ENV['RACK_ENV'] = 'test'
include Rack::Test::Methods

require 'batsd-dash'
require 'batsd-dash/app'

class MiniTest::Spec
  after { mocha_teardown }

  def app
    Batsd::Dash::App
  end

  def json_response
    oid = last_response.object_id

    if oid != @last_response_id
      @last_response_id = oid
      @last_response_json_body = JSON.parse(last_response.body, symbolize_names: true) rescue nil
    end

    @last_response_json_body
  end
end

require 'mocha/setup'
