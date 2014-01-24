require 'spec_helper' 

describe MultipleMan::Listener do 
  class MockClass1; end
  class MockClass2; end

  describe "start" do
    it "should listen to each subscription" do
      MultipleMan::Subscribers::Registry.stub(:subscriptions).and_return([
        mock1 = double(MultipleMan::Subscribers::ModelSubscriber, klass: MockClass1),
        mock2 = double(MultipleMan::Subscribers::ModelSubscriber, klass: MockClass2)
      ])

      mock_listener = double(MultipleMan::Listener)
      MultipleMan::Listener.should_receive(:new).twice.and_return(mock_listener)

      # Would actually be two seperate objects in reality, this is for
      # ease of stubbing.
      mock_listener.should_receive(:listen).twice

      MultipleMan::Listener.start(double(Bunny))
    end
  end

  describe "listen" do
    let(:connection_stub) { double(MultipleMan::Connection, queue: queue_stub, topic: 'app') }
    let(:queue_stub) { double(Bunny::Queue, bind: bind_stub) }
    let(:bind_stub) { double(:bind, subscribe: nil)}

    before { MultipleMan::Listener.stub(:connection).and_return(connection_stub) }

    it "should listen to the right topic, and for all updates to a model" do
      listener = MultipleMan::Listener.new(double(MultipleMan::Subscribers::ModelSubscriber, klass: MockClass1, routing_key: "MockClass1.#", queue_name: "MockClass1"))
      queue_stub.should_receive(:bind).with('app', routing_key: "MockClass1.#")
      listener.listen
    end
  end

  specify "process_message should send the correct data" do
    subscriber = double(MultipleMan::Subscribers::ModelSubscriber, klass: MockClass1, routing_key: "MockClass1.#")
    listener = MultipleMan::Listener.new(subscriber)
    subscriber.should_receive(:create).with({"a" => 1, "b" => 2})
    listener.process_message(OpenStruct.new(routing_key: "app.MockClass1.create"), '{"a":1,"b":2}')
  end
end