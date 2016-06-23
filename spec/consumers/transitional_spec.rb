require 'spec_helper'

describe MultipleMan::Consumers::Transitional do
  let(:listener1) {
    Class.new do
      include MultipleMan::Listener

      def initialize
        self.listen_to = 'SomeClass'
        self.operation = '#'
      end
    end
  }

  it 'wraps errors in ConsumerError' do
    channel = double(Bunny::Channel)
    queue = double(Bunny::Queue, channel: channel).as_null_object

    delivery_info = OpenStruct.new(routing_key: "multiple_man.SomeClass.create")
    payload = '{"a":1,"b":2}'
    allow(queue).to receive(:subscribe).and_yield(delivery_info, double(:meta), payload)

    subscriber = listener1.new
    allow(subscriber).to receive(:create).and_raise('anything')

    allow(channel).to receive(:nack)

    expect(MultipleMan).to receive(:error).with(kind_of(MultipleMan::ConsumerError), kind_of(Hash))
    subject = described_class.new(subscription:subscriber, queue: queue, topic: 'some-topic')
    subject.listen
  end

end
