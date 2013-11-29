require 'spec_helper'

describe MultipleMan::ModelPublisher do 
  let(:bunny_stub) { double(Bunny, create_channel: channel_stub, start: nil, close: nil) }
  let(:channel_stub) { double(Bunny::Channel, topic: topic_stub)}
  let(:topic_stub) { double(Bunny::Exchange, publish: nil) }

  before {
    MultipleMan.configure do |config|
      config.topic_name = "app"
    end

    Bunny.stub(:new).and_return(bunny_stub)
  }

  class MockObject
    def to_json
      '{"foo": "bar"}'
    end

    def model_name
      OpenStruct.new(singular: "mock_object")
    end
  end

  describe "after_commit" do
    it "should queue the update in the correct topic" do
      channel_stub.should_receive(:topic).with("app")
      described_class.new.after_commit(MockObject.new)
    end
    it "should send the jsonified version of the model to the correct routing key" do
      topic_stub.should_receive(:publish).with('{"foo": "bar"}', routing_key: "mock_object.create")
      described_class.new.after_commit(MockObject.new)
    end
  end
end