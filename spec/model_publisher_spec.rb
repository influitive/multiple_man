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
    def foo
      "bar"
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
      MultipleMan::AttributeExtractor.any_instance.should_receive(:to_json).and_return('{"foo": "bar"}')
      topic_stub.should_receive(:publish).with('{"foo": "bar"}', routing_key: "mock_object.create")
      described_class.new(:create, fields: [:foo]).after_commit(MockObject.new)
    end
  end

  its(:topic_name) { should == MultipleMan.configuration.topic_name }

  describe "routing_key" do
    subject { described_class.new(operation, fields: [:foo]).routing_key(MockObject.new) }

    context "creating" do
      let(:operation) { :create }
      it { should == "mock_object.create" }
    end

    context "updating" do
      let(:operation) { :update }
      it { should == "mock_object.update" }
    end

    context "destroying" do
      let(:operation) { :destroy }
      it { should == "mock_object.destroy" }
    end
  end
end