require 'spec_helper'

describe MultipleMan::ModelPublisher do 
  let(:channel_stub) { double(Bunny::Channel, topic: topic_stub)}
  let(:topic_stub) { double(Bunny::Exchange, publish: nil) }

  before {
    MultipleMan::Connection.stub(:connect).and_yield(channel_stub)
    MultipleMan.configure do |config|
      config.topic_name = "app"
    end
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

  subject { described_class.new(fields: [:foo]) }

  describe "publish" do
    it "should send the jsonified version of the model to the correct routing key" do
      MultipleMan::AttributeExtractor.any_instance.should_receive(:as_json).and_return({foo: "bar"})
      topic_stub.should_receive(:publish).with('{"foo":"bar"}', routing_key: "app.MockObject.create", headers:{'version' => '2', 'identify_by' => ['id'].to_json})
      described_class.new(fields: [:foo]).publish(MockObject.new)
    end

    it "should call the error handler on error" do
      ex = Exception.new("Bad stuff happened")
      topic_stub.stub(:publish) { raise ex }
      MultipleMan.should_receive(:error).with(ex)
      described_class.new(fields: [:foo]).publish(MockObject.new)
    end
  end

  describe "with a serializer" do
    class MySerializer
      def initialize(record)
      end
      def as_json
        {a: "yes"}
      end
    end

    subject { described_class.new(with: MySerializer) }

    it "should get its data from the serializer" do
      obj = MockObject.new
      topic_stub.should_receive(:publish).with('{"a":"yes"}', routing_key: "app.MockObject.create", headers: {'version' => '2', 'identify_by' => ['id'].to_json})
      subject.publish(obj)
    end
  end

end