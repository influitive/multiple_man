require 'spec_helper'

describe MultipleMan::AttributeExtractor do 

  MockClass = Struct.new(:a, :b, :c, :id)
  let(:object) { MockClass.new(1,2,3,10) }
  subject { described_class.new(object, fields) }
  let(:fields) { nil }

  context "without fields" do
    it "should not be allowed" do
      expect { described_class.new(object, nil) }.to raise_error 
    end
  end

  context "with fields" do
    let(:fields) { [:a, :c] }
    its(:data) { should == {a: 1, c: 3}}
    its(:as_json) { should == {
      a: 1,
      c: 3
    } }
  end
  
end