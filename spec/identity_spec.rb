require 'spec_helper'

describe MultipleMan::Identity do 
  let(:record) { double(:model, id: 1, foo: 'foo', bar: 'bar' )}
  subject { described_class.new(record, identifier).value }

  context "proc identifier" do
    let(:identifier) { lambda{|record| "#{record.foo}-#{record.id}" } }
    it { should == "foo-1" }
  end
  context "symbol identifier" do
    let(:identifier) { :foo }
    it { should == "foo" }
  end
  context "no identifier" do
    let(:identifier) { :id }
    it { should == "1" }
  end
end