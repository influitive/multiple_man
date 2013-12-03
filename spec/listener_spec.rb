require 'spec_helper' 

describe MultipleMan::Listener do 
  class MockClass1; end
  class MockClass2; end

  describe "start" do
    it "should connect to the queue" do
      MultipleMan::Connection.should_receive(:connect)
      MultipleMan::Listener.start
    end
    it "should listen to each subscription" do
      MultipleMan::ModelSubscriber.stub(:subscriptions).and_return([
        mock1 = double(MultipleMan::ModelSubscriber, klass: MockClass1),
        mock2 = double(MultipleMan::ModelSubscriber, klass: MockClass2)
      ])

      mock_listener = double(MultipleMan::Listener)
      MultipleMan::Listener.should_receive(:new).twice.and_return(mock_listener)

      # Would actually be two seperate objects in reality, this is for
      # ease of stubbing.
      mock_listener.should_receive(:listen).twice

      MultipleMan::Listener.start
    end
  end

  describe "listen" do
    it "should listen to the right topic" do

    end
    it "should listen for all updates to a model" do

    end
  end
end