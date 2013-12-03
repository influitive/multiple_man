require 'spec_helper'

describe MultipleMan::AttributeExtractor do 

  MockClass = Struct.new(:a, :b, :c)
  let(:object) { MockClass.new(1,2,3) }
  subject { described_class.new(object, fields) }

  context "without fields" do
    it "should not be allowed" do
      expect { described_class.new(object, nil) }.to raise_error 
    end
  end

  context "with fields" do
    let(:fields) { [:a, :c] }
    its(:data) { should == {a: 1, c: 3}}
    its(:to_json) { should == '{"a":1,"c":3}'}
  end
  
end