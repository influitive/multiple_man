require 'spec_helper'

describe MultipleMan::SeederListener do
  class MockClass1; end

  let(:connection_stub) { double(MultipleMan::Connection, queue: queue_stub, topic: 'app') }
  let(:queue_stub) { double(Bunny::Queue, bind: bind_stub) }
  let(:bind_stub) { double(:bind, subscribe: nil)}

  before { MultipleMan::Listener.stub(:connection).and_return(connection_stub) }

  it 'listens to seed events' do
    listener = described_class.new(double(MultipleMan::Subscribers::ModelSubscriber,
                                   klass: MockClass1,
                                   routing_key: "seed.MockClass1",
                                   queue_name: "MockClass1"))

    queue_stub.should_receive(:bind).with('app', routing_key: "seed.MockClass1")
    listener.listen
  end
end
