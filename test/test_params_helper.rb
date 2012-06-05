require 'helper'

describe BatsdDash::App do
  before do
    BatsdDash::ConnectionPool::Client.any_instance.stubs(:sync).returns(true)
    BatsdDash::ConnectionPool::Client.any_instance.stubs(:write).returns(true)
    BatsdDash::ConnectionPool::Client.any_instance.stubs(:unbind).returns(true)

    stub_batsd_client_with 'interval' => 10, 'counters:a.b' => []
  end

  describe 'params helper' do
    before do
      header 'Accept', 'application/json'
    end

    describe 'metrics param' do
      it 'returns error on nil metrics' do
        get '/counters'

        last_response.status.must_equal 400
        last_response.body.must_include 'error'
      end

      it 'returns error on empty metrics' do
        get '/counters?metrics[]='

        last_response.status.must_equal 400
        last_response.body.must_include 'error'
      end

      it 'valid with single metrics param' do
        get '/counters?metrics=a.b'

        last_response.status.must_equal 200
        last_response.body.wont_be_empty

        json_response[:metrics].size.must_equal 1
      end

      it 'valid with multiple metrics param' do
        # same statistic is used cause the stub method is rather limited
        get '/counters?metrics[]=a.b&metrics[]=a.b'

        last_response.status.must_equal 200
        last_response.body.wont_be_empty

        json_response[:metrics].size.must_equal 2
      end
    end

    describe 'range params' do
      before do
        @start = Time.now.to_i - 86000
        @stop = Time.now.to_i
      end

      it 'returns error without stop param' do
        get "/counters?metrics[]=a.b&start=#{@start}"

        last_response.status.must_equal 400
        last_response.body.must_include 'error'
      end

      it 'returns error without start param' do
        get "/counters?metrics[]=a.b&stop=#{@stop}"

        last_response.status.must_equal 400
        last_response.body.must_include 'error'
      end

      it 'returns error on invalid range' do
        get "/counters?metrics[]=a.b&start=#{@stop}&stop=#{@start}"

        last_response.status.must_equal 400
        last_response.body.must_include 'error'

        get '/counters?metrics[]=a.b&start=-2&stop=-1'

        last_response.status.must_equal 400
        last_response.body.must_include 'error'
      end
    end
  end
end
