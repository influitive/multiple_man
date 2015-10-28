require 'spec_helper'

describe MultipleMan::Subscriber do
  let(:mock_class) do
    Class.new do

      include MultipleMan::Listener
    end
  end

  describe "listen_to" do
    it "should register itself" do
      MultipleMan.configuration.should_receive(:register_listener).with(instance_of(mock_class))
      mock_class.listen_to "Model"
    end

    it "should have a routing key for what it's listening to" do
      listener = mock_class.listen_to "Model"
      expect(listener.routing_key).to eq("multiple_man.Model.#")
    end
  end
end
