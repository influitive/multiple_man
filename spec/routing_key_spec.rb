require 'spec_helper'

describe MultipleMan::RoutingKey do 
  class MockObject
  end

  describe "to_s" do
    subject { described_class.new(MockObject.new, operation).to_s }

    context "creating" do
      let(:operation) { :create }
      it { should == "MockObject.create" }
    end

    context "updating" do
      let(:operation) { :update }
      it { should == "MockObject.update" }
    end

    context "destroying" do
      let(:operation) { :destroy }
      it { should == "MockObject.destroy" }
    end

    context "not specified" do
      subject { described_class.new(MockObject.new).to_s }
      it { should == "MockObject.#" }
    end
  end

  describe "operation=" do
    [:create, :update, :destroy, :"#"].each do |op|
      it "should allow #{op}" do
        rk = described_class.new(Object)
        rk.operation = op
        rk.operation.should == op
      end
    end

    ["new", nil, "", "create"].each do |op|
      it "should not allow #{op}" do
        rk = described_class.new(Object)
        expect { rk.operation = op }.to raise_error
      end
    end

  end
end