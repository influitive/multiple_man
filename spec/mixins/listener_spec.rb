require 'spec_helper'

describe MultipleMan::Subscriber do
  let(:mock_class) do
    Class.new do
      def self.name
        "MockClass"
      end

      include MultipleMan::Listener
    end
  end

  describe "listen_to" do
    it "should register itself" do
      MultipleMan::Subscribers::Registry.should_receive(:register).with(instance_of(mock_class))
      mock_class.listen_to "Model"
    end

    it "should have a klass equal to the class it's mixed into" do
      listener = mock_class.listen_to "Model"
      expect(listener.klass).to eq("MockClass")
    end

    it "should use it's own class name as the queue name" do
      listener = mock_class.listen_to "Model"
      expect(listener.queue_name).to match(/MockClass\Z/)
    end

    it "should have a routing key for what it's listening to" do
      listener = mock_class.listen_to "Model"
      expect(listener.routing_key).to eq("multiple_man.Model.#")
    end
  end
end
