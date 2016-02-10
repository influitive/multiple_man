require 'spec_helper'

describe MultipleMan::Listeners::Listener do
  class MockClass1; end
  class MockClass2; end

  before { MultipleMan::Connection.stub(:connection).and_return(double(Bunny).as_null_object)}

  describe "start" do
    it "should listen to each subscription" do
      MultipleMan::Subscribers::Registry.stub(:subscriptions).and_return([
        double(MultipleMan::Subscribers::ModelSubscriber, klass: MockClass1),
        double(MultipleMan::Subscribers::ModelSubscriber, klass: MockClass2)
      ])

      mock_listener = double(described_class)
      described_class.should_receive(:new).twice.and_return(mock_listener)

      # Would actually be two seperate objects in reality, this is for
      # ease of stubbing.
      mock_listener.should_receive(:listen).twice

      described_class.start
    end
  end

  describe "listen" do
    let(:connection_stub) { double(MultipleMan::Connection, queue: queue_stub, topic: 'app') }
    let(:queue_stub) { double(Bunny::Queue, bind: bind_stub) }
    let(:bind_stub) { double(:bind, subscribe: nil)}

    before { MultipleMan::Connection.stub(:new).and_return(connection_stub) }

    it "should listen to the right topic, and for all updates to a model" do
      listener = described_class.new(double(MultipleMan::Subscribers::ModelSubscriber, klass: MockClass1, routing_key: "MockClass1.#", queue_name: "MockClass1"))
      queue_stub.should_receive(:bind).with('app', routing_key: "MockClass1.#")
      listener.listen
    end
  end

  specify "process_message should send the correct data" do
    connection_stub = double(MultipleMan::Connection).as_null_object
    MultipleMan::Connection.stub(:new).and_return(connection_stub)
    subscriber = double(MultipleMan::Subscribers::ModelSubscriber, klass: MockClass1, routing_key: "MockClass1.#").as_null_object
    listener = described_class.new(subscriber)

    subscriber.should_receive(:create).with(instance_of(MultipleMan::Payload::V1))

    listener.process_message(MultipleMan::Payload::V1.new(double(:delivery_info, routing_key: 'app.MockClass1.create'), nil, "data" => {'a' => 1, 'b' => 2}))
  end

  specify "process_message should use the payload to determine the operation if it's available" do
    connection_stub = double(MultipleMan::Connection).as_null_object
    MultipleMan::Connection.stub(:new).and_return(connection_stub)
    subscriber = double(MultipleMan::Subscribers::ModelSubscriber, klass: MockClass1, routing_key: "MockClass1.#").as_null_object
    listener = described_class.new(subscriber)

    subscriber.should_receive(:create)

    listener.process_message(MultipleMan::Payload::V1.new(double(:delivery_info, routing_key: 'app.MockClass1, update'), nil, "operation" => "create", "data" => {'a' => 1, 'b' => 2}))
  end
end
