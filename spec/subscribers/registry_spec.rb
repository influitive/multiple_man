require 'spec_helper'

describe MultipleMan::Subscribers::Registry do
  describe "register" do
    it "should add a subscriber" do
      subscription = double(:subscriber)
      described_class.register(subscription)
      described_class.subscriptions.should include subscription
    end
  end
end
