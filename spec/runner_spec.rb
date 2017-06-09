require 'spec_helper'

describe MultipleMan::Runner do
  let(:mock_channel) { double("Channel", prefetch: true, queue: true) }
  let(:mock_connection) { double("Connection", create_channel: mock_channel) }
  let(:mock_consumer) { double("Consumer", listen: true) }

  it 'boots app and listens on new channel' do
    expect(MultipleMan::Connection).to receive(:connection).and_return(mock_connection)
    expect(MultipleMan::Consumers::General).to receive(:new).and_return(mock_consumer)

    expect(mock_consumer).to receive(:listen)

    runner = described_class.new(mode: :general)
    runner.run
  end
end
