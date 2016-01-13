require 'spec_helper'

describe MultipleMan::Subscribers::ModelSubscriber do
  class MockClass

  end

  let(:payload) {
    MultipleMan::Payload::V1.new(nil, nil, {
      'id' => {'id' => 5 },
      'data' => {'a' => 1, 'b' => 2}
    })
  }

  describe "initialize" do
    it "should listen to the object passed in for to" do
      subscriber = described_class.new(MockClass, to: 'PublishedClass')
      expect(subscriber.klass).to eq("PublishedClass")
    end
  end

  describe "create" do
    it "should create a new model" do
      mock_object = MockClass.new
      MockClass.stub(:where).and_return([mock_object])
      mock_populator = double(MultipleMan::ModelPopulator)
      MultipleMan::ModelPopulator.should_receive(:new).and_return(mock_populator)
      mock_populator.should_receive(:populate).with(payload)
      mock_object.should_receive(:save!)

      described_class.new(MockClass, {}).create(payload)
    end
  end

  describe "find_model" do
    it "should find by the hash for multiple fields" do
      mock_object = double(MockClass).as_null_object
      MockClass.should_receive(:where).with('id' => 5).and_return([mock_object])
      described_class.new(MockClass, {}).create(payload)
    end
  end

  describe "destroy" do
    it "should destroy the model" do
      mock_object = MockClass.new
      MockClass.should_receive(:where).and_return([mock_object])
      mock_object.should_receive(:destroy!)

      described_class.new(MockClass, {}).destroy(payload)
    end
  end
end
