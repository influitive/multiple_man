require 'spec_helper'

describe MultipleMan::AttributeExtractor do 

  MockClass = Struct.new(:a, :b, :c, :id)
  let(:object) { MockClass.new(1,2,3,10) }
  subject { described_class.new(object, fields, identifier) }
  let(:fields) { nil }
  let(:identifier) { nil }

  context "without fields" do
    it "should not be allowed" do
      expect { described_class.new(object, nil) }.to raise_error 
    end
  end

  context "with fields" do
    let(:fields) { [:a, :c] }
    its(:data) { should == {id:10, data:{a: 1, c: 3}}}
    its(:to_json) { should == '{"id":10,"data":{"a":1,"c":3}}'}
  end

  context "with an identifier" do
    let(:fields) { [:a] }
    context "symbol" do
      let(:identifier) { :a }
      its(:data) { should == {id:1, data:{a: 1}}}
      its(:to_json) { should == '{"id":1,"data":{"a":1}}'}
    end
    context "proc" do
      let(:identifier) { lambda{|record| record.b } }
      its(:data) { should == {id:2, data:{a: 1}}}
      its(:to_json) { should == '{"id":2,"data":{"a":1}}'}
    end
  end
  
end