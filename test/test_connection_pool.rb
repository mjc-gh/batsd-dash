require 'helper'

describe BatsdDash::ConnectionPool do
  let(:pool) { BatsdDash::ConnectionPool }
  let(:client) { BatsdDash::ConnectionPool::Client }

  it "should start reconnect timer after disconnect" do
    client.stubs(:new).raises(SocketError)

    pool.initialize_connection_pool

    EM.next_tick {
      pool.instance_variable_get(:@timer_active).tap { |timer|
        timer.wont_be_nil
        timer.must_be_instance_of EM::Timer
      }
    }
  end
end

