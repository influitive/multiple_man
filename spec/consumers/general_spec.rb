require 'spec_helper'

describe MultipleMan::Consumers::General do
  let(:listener1) {
    Class.new do
      include MultipleMan::Listener

      def initialize
        self.listen_to = 'SomeClass'
        self.operation = '#'
      end
    end
  }

  let(:listener2) {
    Class.new do
      include MultipleMan::Listener

      def initialize
        self.listen_to = 'SomeOtherClass'
        self.operation = '#'
      end
    end
  }

  it "listens to each subscription" do
    subscriptions = [listener1.new, listener2.new]
    queue = double(Bunny::Queue)

    expect(queue).to receive(:bind).with('some-topic', routing_key: subscriptions.first.routing_key).ordered
    expect(queue).to receive(:bind).with('some-topic', routing_key: subscriptions.last.routing_key).ordered
    expect(queue).to receive(:subscribe).with(block: true, manual_ack: true).ordered

    subject = described_class.new(subscribers: subscriptions, queue: queue, topic: 'some-topic')

    subject.listen
  end

  it "sends the correct data" do
    channel = double(Bunny::Channel)
    queue = double(Bunny::Queue, channel: channel).as_null_object

    subscriber = listener1.new
    subject = described_class.new(subscribers:[subscriber], queue: queue, topic: 'some-topic')

    expect(channel).to receive(:acknowledge)
    expect(subscriber).to receive(:create).with({"a" => 1, "b" => 2})

    delivery_info = OpenStruct.new(routing_key: "multiple_man.SomeClass.create")
    payload = '{"a":1,"b":2}'
    allow(queue).to receive(:subscribe).and_yield(delivery_info, double(:meta), payload)

    subject.listen
  end

  it "uses the payload to determine the operation if it's available" do
    channel = double(Bunny::Channel).as_null_object
    queue = double(Bunny::Queue, channel: channel).as_null_object

    subscriber = listener1.new
    subject = described_class.new(subscribers:[subscriber], queue: queue, topic: 'some-topic')

    delivery_info = OpenStruct.new(routing_key: "multiple_man.SomeClass.some_other_operation")
    payload = '{"operation": "create", "a":1,"b":2}'
    allow(queue).to receive(:subscribe).and_yield(delivery_info, double(:meta), payload)

    subscriber.should_receive(:create)

    subject.listen
  end

  it "sends a nack on failure" do
    allow(MultipleMan.configuration).to receive(:error_handler) { double(:handler).as_null_object}

    channel = double(Bunny::Channel)
    queue = double(Bunny::Queue, channel: channel).as_null_object

    delivery_info = OpenStruct.new(routing_key: "multiple_man.SomeClass.create")
    payload = '{"a":1,"b":2}'
    allow(queue).to receive(:subscribe).and_yield(delivery_info, double(:meta), payload)

    subscriber = listener1.new
    allow(subscriber).to receive(:create).and_raise('anything')

    expect(channel).to receive(:nack)
    subject = described_class.new(subscribers:[subscriber], queue: queue, topic: 'some-topic')
    subject.listen
  end

  it 'wraps errors in ConsumerError' do
    channel = double(Bunny::Channel)
    queue   = double(Bunny::Queue, channel: channel).as_null_object
    error   = ArgumentError.new("undefined method `foo' for nil:NilClass")
    error.set_backtrace(["file.rb:1 'foo'"])

    delivery_info = OpenStruct.new(routing_key: "multiple_man.SomeClass.create")
    payload = '{"a":1,"b":2}'
    allow(queue).to receive(:subscribe).and_yield(delivery_info, double(:meta), payload)

    subscriber = listener1.new
    allow(subscriber).to receive(:create).and_raise(error)

    allow(channel).to receive(:nack)

    expect(MultipleMan.logger).to receive(:debug).with('Starting listeners.')
    expect(MultipleMan.logger).to receive(:debug).with('Processing message for multiple_man.SomeClass.create.')
    expect(MultipleMan.logger).to receive(:debug).with("\tMultipleMan::ConsumerError #{error.message} \n#{error.backtrace}")
    expect(MultipleMan).to receive(:error).with(kind_of(MultipleMan::ConsumerError), kind_of(Hash))
    subject = described_class.new(subscribers:[subscriber], queue: queue, topic: 'some-topic')
    subject.listen
  end
end
