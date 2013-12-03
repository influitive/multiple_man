require 'spec_helper'

describe MultipleMan::Subscriber do 
  class MockClass

  end

  describe "inclusion" do
    it "should register itself" do
      MultipleMan::ModelSubscriber.should_receive(:register).with(MockClass)
      MockClass.send(:include, MultipleMan::Subscriber)
    end 
  end
end