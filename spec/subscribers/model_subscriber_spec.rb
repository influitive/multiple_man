require 'spec_helper'

describe MultipleMan::Subscribers::ModelSubscriber do
  class MockClass

  end

  describe "create" do
    it "should create a new model" do
      mock_object = MockClass.new
      MockClass.stub(:find_or_initialize_by).with(multiple_man_identifier: 5).and_return(mock_object)
      mock_populator = double(MultipleMan::ModelPopulator)
      MultipleMan::ModelPopulator.should_receive(:new).and_return(mock_populator)
      mock_populator.should_receive(:populate).with({a: 1, b: 2}, nil)
      mock_object.should_receive(:save!)

      described_class.new(MockClass, {}).create({id: 5, data:{a: 1, b: 2}})
    end
  end

  describe "destroy" do
    it "should destroy the model" do
      mock_object = MockClass.new
      MockClass.should_receive(:find_or_initialize_by).and_return(mock_object)
      mock_object.should_receive(:destroy!)

      described_class.new(MockClass, {}).destroy({id: 1})
    end
  end

  specify "routing_key should be the model name and a wildcard" do
    described_class.new(MockClass, {}).routing_key.should == "app.MockClass.#"
  end

  specify "queue name should be the app name + class" do
    MultipleMan.configure do |config|
      config.app_name = "test"
    end
    described_class.new(MockClass, {}).queue_name.should == "app.test.MockClass"
  end
end