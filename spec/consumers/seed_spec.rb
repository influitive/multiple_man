require 'spec_helper'

describe MultipleMan::Consumers::Seed do
  let(:listener1) {
    Class.new do
      include MultipleMan::Listener

      def initialize
        self.listen_to = 'SomeClass'
        self.operation = '#'
      end
    end
  }

  it 'binds for seeding' do
    channel = double(Bunny::Channel).as_null_object
    queue = double(Bunny::Queue, channel: channel)

    expect(queue).to receive(:bind).with('some-topic', routing_key: "multiple_man.seed.SomeClass")
    expect(queue).to receive(:subscribe).with(manual_ack: true)

    subject = described_class.new(subscribers: [listener1.new], queue: queue, topic: 'some-topic')
    subject.listen
  end

  it "sends the correct data" do
    channel = double(Bunny::Channel)
    queue = double(Bunny::Queue, channel: channel).as_null_object

    subscriber = listener1.new
    subject = described_class.new(subscribers:[subscriber], queue: queue, topic: 'some-topic')

    expect(channel).to receive(:acknowledge)
    expect(subscriber).to receive(:create).with({"a" => 1, "b" => 2})

    delivery_info = OpenStruct.new(routing_key: "multiple_man.seed.SomeClass")
    payload = '{"a":1,"b":2}'
    allow(queue).to receive(:subscribe).and_yield(delivery_info, double(:meta), payload)

    subject.listen
  end

end
