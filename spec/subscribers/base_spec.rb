require 'spec_helper'

describe MultipleMan::Subscribers::Base do
  class MockClass
  end

  specify "routing_key should be the model name and a wildcard" do
    described_class.new(MockClass).routing_key.should =~ /\.MockClass\.\#$/
  end

  specify "it should be alright to use a string for a class name" do
    described_class.new("MockClass").routing_key.should =~ /\.MockClass\.\#$/
  end
end
