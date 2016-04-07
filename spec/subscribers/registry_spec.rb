require 'spec_helper'

describe MultipleMan::Subscribers::Registry do
  describe "register" do
    it "should add a subscriber" do
      subscription = double(:subscriber)

      subject.register(subscription)
      subject.subscriptions[0].should == subscription
    end
  end
end
