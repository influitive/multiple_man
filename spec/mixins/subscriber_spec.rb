require 'spec_helper'

describe MultipleMan::Subscriber do
  class MockClass
    include MultipleMan::Subscriber
  end

  describe "subscribe" do
    it "should register itself" do
      expect(MultipleMan.configuration).to receive(:register_listener).with(instance_of(MultipleMan::Subscribers::ModelSubscriber))
      MockClass.subscribe fields: [:foo, :bar]
    end
  end
end
