require 'spec_helper'

describe MultipleMan::Runner do
  let(:mock_channel) { double("Channel", prefetch: true, queue: true) }
  let(:mock_connection) { double("Connection", create_channel: mock_channel) }
  let(:mock_consumer) { double("Consumer", listen: true) }
  let(:pool_stub) { double(ConnectionPool) }

  it 'boots app and listens on new channel' do
    MultipleMan::Connection.stub(:channel_pool).and_return(pool_stub)
    pool_stub.stub(:with).and_yield(mock_channel)
    expect(MultipleMan::Consumers::General).to receive(:new).and_return(mock_consumer)
    expect(mock_consumer).to receive(:listen)

    runner = described_class.new(mode: :general)
    runner.run
  end

  context "shutdown" do
    it 'closes connections and exits gracefully' do
      MultipleMan::Consumers::General.stub(:new) { Process.kill('INT', 0) }

      expect(MultipleMan::Connection).to receive(:close)

      MultipleMan::Runner.new.run
    end
  end
end
