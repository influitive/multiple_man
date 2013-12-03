require 'spec_helper'

describe MultipleMan::ModelSubscriber do
  class MockClass
  end

  describe "register" do 
    it "should add a subscriber" do
      MultipleMan::ModelSubscriber.register(MockClass)
      MultipleMan::ModelSubscriber.subscriptions[0].klass.should == MockClass
    end
  end

  describe "create" do
    it "should create a new model" do
      mock_object = MockClass.new
      MockClass.should_receive(:new).with({a: 1, b: 2}).and_return(mock_object)
      mock_object.should_receive(:save)

      MultipleMan::ModelSubscriber.new(MockClass).create({a: 1, b: 2})
    end
  end

  describe "update" do
    it "should find an existing model and update it" do
      mock_object = MockClass.new
      MockClass.should_receive(:find_by_remote_id).and_return(mock_object)
      mock_object.should_receive(:attributes=)
      mock_object.should_receive(:save)

      MultipleMan::ModelSubscriber.new(MockClass).update({id: 5, a: 1, b: 2})
    end
  end

  describe "destroy" do
    it "should destroy the model" do
      mock_object = MockClass.new
      MockClass.should_receive(:find_by_remote_id).and_return(mock_object)
      mock_object.should_receive(:destroy)

      MultipleMan::ModelSubscriber.new(MockClass).destroy({id: 1})
    end
  end
end