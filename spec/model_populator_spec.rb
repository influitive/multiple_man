require 'spec_helper'

describe MultipleMan::ModelPopulator do 
  class MockModel
    attr_accessor :a, :b
  end

  describe "populate" do
    let(:model) { MockModel.new }
    let(:data) { { a: 1, b: 2 } }
    subject { described_class.new(model, fields).populate(data) }

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