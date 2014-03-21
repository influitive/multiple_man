require 'spec_helper'

describe MultipleMan::Subscribers::Base do
  class MockClass
  end

  specify "routing_key should be the model name and a wildcard" do
    described_class.new(MockClass).routing_key.should == "app.MockClass.#"
  end

  specify "routing_key should be the model name and a wildcard with the passed operation" do
    described_class.new(MockClass).routing_key(:seed).should == "app.MockClass.seed"
  end

  specify "queue name should be the app name + class" do
    MultipleMan.configure do |config|
      config.app_name = "test"
    end
    described_class.new(MockClass).queue_name.should == "app.test.MockClass"
  end
end
