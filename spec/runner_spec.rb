require 'spec_helper'

describe MultipleMan::Runner do
  let(:mock_queue) { double('Queue') }
  let(:mock_channel) { double("Channel", prefetch: true, queue: mock_queue) }
  let(:mock_connection) { double("Connection", create_channel: mock_channel) }
  let(:mock_consumer) { double("Consumer", listen: true) }

  describe 'run' do
    let(:runner) { described_class.new(mode: :general) }
    before do
      allow(mock_queue).to receive(:channel).and_return(mock_channel)
      allow(mock_channel).to receive(:exchange)
      allow(MultipleMan::Connection).to receive(:connection).and_return(mock_connection)
      allow(MultipleMan::Consumers::General).to receive(:new).and_return(mock_consumer)
    end

    it 'boots app and listens on new channel' do
      expect(mock_consumer).to receive(:listen)
      runner.run
    end

    it 'listener and queue availability' do
      runner.run
      expect(runner.listener).not_to be_nil
      expect(runner.queue).not_to be_nil
    end
  end

  context 'shutdown' do
    let(:connection) { MultipleMan::Connection.connection }

    it 'closes connections and exits gracefully' do
      klass = MultipleMan::Consumers::General
      allow_any_instance_of(klass).to receive(:listen) do
        raise MultipleMan::Runner::ShutDown
      end
      expect(connection).to receive(:close).at_least(1)
      MultipleMan::Runner.new.run
    end
  end

  describe 'rspec utilities' do
    class MockClass
      include MultipleMan::Subscriber
      subscribe fields: %i[id name]
      attr_accessor :name
    end

    let(:runner) { MultipleMan::Runner.new(mode: :general) }
    before do
      allow_any_instance_of(MultipleMan::Consumers::General).to receive(:listen)
    end

    it '#publish_test_message' do
      runner.run
      expect(runner.queue).to receive(:publish)
      runner.publish_test_message('MockClass', name: 'name')
    end

    it '#listener_for' do
      runner.run
      res = runner.listener_for('MockClass')
      expect(res).to be_an_instance_of(MultipleMan::Subscribers::ModelSubscriber)
    end
  end
end
