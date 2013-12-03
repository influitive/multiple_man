require 'spec_helper'

describe MultipleMan::ModelSubscriber do
  class MockClass
  end

  describe "register" do 
    it "should add a subscriber" do
      MultipleMan::ModelSubscriber.register(MockClass)
      MultipleMan::ModelSubscriber.subscriptions.should include MockClass
    end
  end
end