require 'spec_helper'

describe MultipleMan::Identity do 
  let(:record) { double(:model, id: 1, foo: 'foo', bar: 'bar' )}

  context "with identifier" do
    subject { described_class.build(record, identifier: identifier).value }
    let(:identifier) { :id }

    context "proc identifier" do
      let(:identifier) { lambda{|record| "#{record.foo}-#{record.id}" } }
      it { should == "foo-1" }
    end
    context "symbol identifier" do
      let(:identifier) { :foo }
      it { should == "foo" }
    end
    context "id identifier" do
      let(:identifier) { :id }
      it { should == "1" }
    end
    it "should log a deprecation notice" do
      MultipleMan.logger.should_receive(:warn)
      subject
    end
  end

  context "with identify_by" do
    subject { described_class.build(record, identify_by: identify_by).value }
    context "single field" do
      let(:identify_by) { :foo }
      it { should == { foo: 'foo'} }
    end
    context "no identify_by" do
      let(:identify_by) { nil }
      it { should == { id: 1 } }
    end
    context "multiple_fields" do
      let(:identify_by) { [:foo, :bar] }
      it { should == { foo: 'foo', bar: 'bar' } }
    end
  end
end