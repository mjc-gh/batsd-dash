require 'turn'
require 'mocha'
require 'sinatra/test_helpers'
require 'minitest/autorun'
require 'rack/test'

ENV['RACK_ENV'] = 'test'
include Rack::Test::Methods

# require the app itself
require 'batsd-dash'

# setup a MockSesion
module Rack
  class MockSession
    alias_method :request_original, :request
    def request(uri, env)
      EM.synchrony { EM.next_tick { request_original(uri, env); EM.stop } }
    end
  end
end


class MiniTest::Spec
  after { mocha_teardown }

  def app
    BatsdDash::App
  end

  def stub_batsd_client_with(databits)
    BatsdDash::ConnectionPool::Client.any_instance.stubs(:read_json).returns(databits)
  end

  def json_response
    oid = last_response.object_id

    if oid != @last_response_id
      @last_response_id = oid
      @last_response_json_body = Yajl::Parser.parse(last_response.body, symbolize_keys: true) rescue nil
    end

    @last_response_json_body
  end
end
