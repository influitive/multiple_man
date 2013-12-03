require 'spec_helper'

describe MultipleMan::Publisher do 
  class MockClass
    class << self
      attr_accessor :subscriber

      def after_commit(subscriber, operation)
        self.subscriber = subscriber
      end
    end

    include MultipleMan::Publisher

    def save
      self.class.subscriber.after_commit(self)
    end
  end

  describe "including" do
    it "should add an after commit hook" do
      # once for each operation
      MockClass.should_receive(:after_commit).exactly(3).times
      MockClass.publish
    end
  end

  describe "publish" do
    before { MockClass.publish }
    it "should tell ModelPublisher to publish" do
      my_mock = MockClass.new
      mock_publisher = double(MultipleMan::ModelPublisher)
      MultipleMan::ModelPublisher.any_instance.should_receive(:after_commit).with(my_mock)
      my_mock.save
    end 
  end
end