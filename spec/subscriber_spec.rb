require 'spec_helper'

describe MultipleMan::Subscriber do 
  class MockClass
    include MultipleMan::Subscriber
  end

  describe "subscribe" do
    it "should register itself" do
      MultipleMan::ModelSubscriber.should_receive(:register).with(MockClass, {fields: [:foo, :bar]})
      MockClass.subscribe fields: [:foo, :bar]
    end 
  end
end