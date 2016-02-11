require 'spec_helper'

describe MultipleMan::Payload do
  let(:properties) { Class.new do 
    attr_accessor :headers
    def initialize(version)
        self.headers = {"version" => version}
    end
  end }
  
  describe "::build" do
    it "should assume v1 for a nil version" do
      
      payload = described_class.build(nil, properties.new(nil), nil)
      payload.should be_instance_of(MultipleMan::Payload::V1)
    end
    it "should support v1" do
      payload = described_class.build(nil, properties.new("1"), nil)
      payload.should be_instance_of(MultipleMan::Payload::V1)
    end
    it "should support v2" do
      payload = described_class.build(nil, properties.new("2"), nil)
      payload.should be_instance_of(MultipleMan::Payload::V2)
    end
    it "should fail on an unknown version" do
      expect{ described_class.build(nil, properties.new("3"), nil)}.to raise_exception
    end
  end
end
