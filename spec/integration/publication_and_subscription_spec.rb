require 'spec_helper'

describe "Testing publication and subscription" do 
  let(:MockPublish) do 
    Class.new do
      include MultipleMan::Publisher
      publish fields: [:id, :name], as: 'MockSubscribe'

      attr_accessor :id, :name
    end
  end

  let(:MockSubscribe) do 
    Class.new do
      include MultipleMan::Subscriber
      subscribe fields: [:id, :name]

      attr_accessor :id, :name
    end
  end

  it "should publish and subscribe to records" do
    
    
    p = MockPublish.new
    p.multiple_man_publish(:create)
  end
  
end