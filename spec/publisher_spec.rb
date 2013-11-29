require 'spec_helper'

describe MultipleMan::Publisher do 
  class MockClass
    class << self
      attr_accessor :subscriber
      
      def after_commit(subscriber)
        self.subscriber = subscriber
      end
    end

    def save
      self.class.subscriber.after_commit(self)
    end
  end

  describe "including" do
    it "should add an after commit hook" do
      MockClass.should_receive(:after_commit)
      MockClass.send(:include, MultipleMan::Publisher)
    end
  end

  describe "publish" do
    before { MockClass.send(:include, MultipleMan::Publisher) }
    it "should tell ModelPublisher to publish" do
      my_mock = MockClass.new
      mock_publisher = double(MultipleMan::ModelPublisher)
      MultipleMan::ModelPublisher.any_instance.should_receive(:after_commit).with(my_mock)
      my_mock.save
    end 
  end
end