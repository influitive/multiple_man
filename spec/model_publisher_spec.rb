require 'spec_helper'

describe MultipleMan::ModelPublisher do 
  let(:channel_stub) { double(Bunny::Channel, topic: topic_stub, close: nil)}
  let(:topic_stub) { double(Bunny::Exchange, publish: nil) }

  before {
    MultipleMan.configure do |config|
      config.topic_name = "app"
    end

    MultipleMan::Connection.stub(:open_channel).and_return(channel_stub)
  }

  class MockObject
    def foo
      "bar"
    end

    def id
      10
    end

    def model_name
      OpenStruct.new(singular: "mock_object")
    end
  end

  subject { described_class.new(:create, fields: [:foo]) }

  describe "after_commit" do
    it "should queue the update in the correct topic" do
      channel_stub.should_receive(:topic).with("app")
      described_class.new(:create, fields: [:foo]).after_commit(MockObject.new)
    end
    it "should send the jsonified version of the model to the correct routing key" do
      MultipleMan::AttributeExtractor.any_instance.should_receive(:to_json).and_return('{"id":10,"data":{"foo": "bar"}}')
      topic_stub.should_receive(:publish).with('{"id":10,"data":{"foo": "bar"}}', routing_key: "app.MockObject.create")
      described_class.new(:create, fields: [:foo]).after_commit(MockObject.new)
    end
  end

end