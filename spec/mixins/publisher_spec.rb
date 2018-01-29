require 'spec_helper'

describe MultipleMan::Publisher do
  class MockClass
    class << self
      attr_accessor :subscriber

      def after_commit(subscriber)
        self.subscriber = subscriber
      end
    end

    include MultipleMan::Publisher

    def save
      self.multiple_man_publish
    end
  end

  describe "including" do
    it "should add an after commit hook" do
      # once for each operation
      MockClass.publish
      MockClass.multiple_man_publisher.should be_kind_of MultipleMan::ModelPublisher
    end
  end

  describe "publish" do
    before { MockClass.publish }
    it "should tell ModelPublisher to publish" do
      my_mock = MockClass.new
      mock_publisher = double(MultipleMan::ModelPublisher)
      MultipleMan::ModelPublisher.any_instance
                                 .should_receive(:publish)
                                 .with(my_mock, :create, { outbox: false })
      my_mock.save
    end
  end
end
