require 'spec_helper'

describe MultipleMan::Subscribers::ModelSubscriber do
  class MockClass

  end

  describe "create" do
    it "should create a new model" do
      mock_object = MockClass.new
      MockClass.stub(:where).and_return([mock_object])
      mock_populator = double(MultipleMan::ModelPopulator)
      MultipleMan::ModelPopulator.should_receive(:new).and_return(mock_populator)
      mock_populator.should_receive(:populate).with(id: {id:5}, data: {a: 1, b: 2})
      mock_object.should_receive(:save!)

      described_class.new(MockClass, {}).create({id: {id: 5}, data:{a: 1, b: 2}})
    end
  end

  describe "find_model" do
    it "should find by multiple_man_identifier for a single field" do
      mock_object = double(MockClass).as_null_object
      MockClass.should_receive(:where).with(multiple_man_identifier: 5).and_return([mock_object])
      described_class.new(MockClass, {}).create({id: 5, data:{a: 1, b: 2}})
    end
    it "should find by the hash for multiple fields" do
      mock_object = double(MockClass).as_null_object
      MockClass.should_receive(:where).with(foo: 'bar').and_return([mock_object])
      described_class.new(MockClass, {}).create({id: {foo: 'bar'}, data:{a: 1, b: 2}})
    end
  end

  describe "destroy" do
    it "should destroy the model" do
      mock_object = MockClass.new
      MockClass.should_receive(:where).and_return([mock_object])
      mock_object.should_receive(:destroy!)

      described_class.new(MockClass, {}).destroy({id: 1})
    end
  end
end