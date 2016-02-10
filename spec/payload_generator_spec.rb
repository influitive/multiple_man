require 'spec_helper'

describe MultipleMan::PayloadGenerator do 
  class PayloadMockClass < Struct.new(:foo, :bar)
  end

  let(:mock_object) { PayloadMockClass.new(1,2) }

  describe "data" do
    context "with a serializer" do
      it "should return stuff from the serializer" do
        serializer = Struct.new(:record) do
          def as_json
            {a: 1, b: 2}
          end
        end

        described_class.new(mock_object, :create, {with: serializer}).data.should == {a: 1, b: 2}
      end
    end
    context "without a serializer" do
      it "should call the attribute extractor" do
        MultipleMan::AttributeExtractor.any_instance.stub(:as_json).and_return({c: 3, d: 4})
        described_class.new(mock_object, :create, { fields: [:c, :d] }).data.should == {c: 3, d: 4}
      end
    end
  end
  
  describe "payload" do
    it "should output data" do
      MultipleMan::AttributeExtractor.any_instance.stub(:as_json).and_return({c: 3, d: 4})
      described_class.new(mock_object, :create, { fields: [:c, :d] }).payload.should == {c: 3, d: 4}.to_json
    end  
  end

  describe "headers" do
    it "should output version 2" do
      described_class.new(mock_object, :create, { fields: [:c, :d] }).headers['version'].should == '2'
    end  
    it "should include identity_by headers" do
      described_class.new(mock_object, :create, { fields: [:c, :d] }).headers['identify_by'].should == ['id'].to_json
    end
    it "should support custom identify by information" do
      described_class.new(mock_object, :create, { identify_by: [:c, :d], fields: [:c, :d] }).headers['identify_by'].should == ['c', 'd'].to_json
    end
  end

  describe "record_type" do
    it "should use the as option if available" do
      expect(described_class.new(mock_object).type).to eq("PayloadMockClass")
    end
    it "should use the class otherwise" do
      expect(described_class.new(mock_object, :create, { as: 'FooClass'}).type).to eq("FooClass")
    end
  end
end