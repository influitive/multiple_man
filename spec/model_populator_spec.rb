require 'spec_helper'

describe MultipleMan::ModelPopulator do
  class MockModel
    attr_accessor :a, :b, :id
  end

  describe "populate" do
    let(:model) { MockModel.new }
    let(:payload) { MultipleMan::Payload::V2.new(nil, properties, data)}
    let(:data) { { 'a' => 1, 'b' => 2, 'id' => 1 } }
    let(:properties) { double(:properties, headers: { 'identify_by' => ['id'].to_json })}
    let(:fields) { nil }
    subject { described_class.new(model, fields).populate(payload) }

    its(:id) { should == 1 }

    context "with fields defined" do
      let(:fields) { [:a] }

      its(:b) { should == nil }
      its(:a) { should == 1 }

      context "when a property doesn't exist" do
        before { model.stub(:respond_to?) { false } }
        it "should raise an error" do
          expect { subject }.to raise_error
        end
      end
    end

    context "with fields as a hash" do
      let(:fields) { { b: :a } }

      its(:b) { should == nil }
      its(:a) { should == 2 }
    end
    context "record has source id" do
      let(:model) { Class.new do
        attr_accessor :source_id, :id
      end.new }
      let(:data) { { 'id' => 1 }}

      its(:source_id) { should == 1 }
      its(:id) { should be_nil }
    end
    context "record does not have source id" do
      let(:model) { Class.new do
        attr_accessor :id
      end.new }
      let(:data) { { 'id' => 1 }}

      its(:id) { should == 1 }
    end
    context "without fields defined" do
      let(:fields) { nil }

      its(:b) { should == 2 }
      its(:a) { should == 1 }

      context "when a property doesn't exist" do
        it "should go on it's merry way" do
          expect { subject }.to_not raise_error
        end
      end
    end
  end
end
