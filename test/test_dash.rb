require 'helper'

describe BatsdDash::App do
	before do
		header 'Accept', 'application/json'

		# batsd wouldn't return this much data but w/e
		df = EventMachine::DefaultDeferrable.new
		df.succeed 'interval' => 10, 'counters:a.b' => [], 'timers:c.d' => [], 'gauges:e.f' => []

		BatsdDash::ConnectionPool::Client.any_instance.stubs(:sync).returns(true)
		BatsdDash::ConnectionPool::Client.any_instance.stubs(:unbind).returns(true)

		EM::Synchrony::ConnectionPool.any_instance.stubs(:async_values).returns(df)
	end

	it 'returns error on nil metrics' do
		get '/data'

		last_response.status.must_equal 400
		last_response.body.must_include 'error'
	end

	it 'returns error on empty metrics' do
		get '/data?counters[]='

		last_response.status.must_equal 400
		last_response.body.must_include 'error'
	end

	it 'valid with counter param' do
		get '/data?counters=a.b'

		last_response.status.must_equal 200
		last_response.body.wont_be_empty

		json_response[:results].size.must_equal 1
	end

	it 'valid with timer param' do
		get '/data?timers=c.d'

		last_response.status.must_equal 200
		last_response.body.wont_be_empty

		json_response[:results].size.must_equal 1
	end

	it 'valid with gauge param' do
		get '/data?gauges=e.f'

		last_response.status.must_equal 200
		last_response.body.wont_be_empty

		json_response[:results].size.must_equal 1
	end

	it 'valid with multiple' do
		get '/data?counters[]=a.b&timers[]=d.c&gauges[]=e.f'

		last_response.status.must_equal 200
		last_response.body.wont_be_empty

		json_response[:results].size.must_equal 3
	end

	describe 'range params' do
		before do
			@start = Time.now.to_i - 86000
			@stop = Time.now.to_i
		end

		it 'returns error without stop param' do
			get "/data?counters[]=a.b&start=#{@start}"

			last_response.status.must_equal 400
			last_response.body.must_include 'error'
		end

		it 'returns error without start param' do
			get "/data?counters[]=a.b&stop=#{@stop}"

			last_response.status.must_equal 400
			last_response.body.must_include 'error'
		end

		it 'returns error on invalid range' do
			get "/data?counters[]=a.b&start=#{@stop}&stop=#{@start}"

			last_response.status.must_equal 400
			last_response.body.must_include 'error'

			get '/data?counters[]=a.b&start=-2&stop=-1'

			last_response.status.must_equal 400
			last_response.body.must_include 'error'
		end
	end
end
