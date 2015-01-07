require 'spec_helper'

describe MultipleMan::AttributeExtractor do 

  MockClass = Struct.new(:a, :b, :c, :id)
  let(:object) { MockClass.new(1,2,3,10) }
  subject { described_class.new(object, fields, include_previous) }
  let(:fields) { nil }
  let(:include_previous) { false }

  context "without fields" do
    it "should not be allowed" do
      expect { described_class.new(object, nil) }.to raise_error 
    end
  end

  context "with fields" do
    let(:fields) { [:a, :c] }
    its(:as_json) { should == {
      a: 1,
      c: 3
    } }
  end

  context "including old fields" do
    let(:object) { Struct.new(:a,:b,:a_was,:b_was).new("new_a", "new_b", "old_a", "old_b") }
    let(:fields) { [:a, :b] }
    let(:include_previous) { true }
    its(:as_json) { should == {a: 'new_a', b: 'new_b', previous: { a: 'old_a', b: 'old_b' }}}
  end
  
end