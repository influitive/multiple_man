require 'spec_helper'

describe MultipleMan::PayloadGenerator do 
  class PayloadMockClass < Struct.new(:foo, :bar)
  end

  let(:mock_object) { PayloadMockClass.new(1,2) }

  describe "operation" do
    it "should be whatever was passed in" do
      expect(described_class.new(mock_object, :update).operation).to eq('update')
    end
    it "should be create by default" do
      expect(described_class.new(mock_object).operation).to eq('create')
    end
  end

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

  describe "id" do
    it "should defer to identity" do
      MultipleMan::Identity::MultipleField.any_instance.stub(:value).and_return("foo_1")
      described_class.new(mock_object).id.should == "foo_1"
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