require 'spec_helper'

describe MultipleMan::Connection do

  let(:mock_bunny) { double(Bunny) }
  let(:mock_channel) { double(Bunny::Channel, close: nil) }

  describe "connect" do
    it "should open a connection and a channel" do
      mock_bunny.should_receive(:start)
      Bunny.should_receive(:new).and_return(mock_bunny)
      mock_bunny.should_receive(:create_channel).once.and_return(mock_channel)

      described_class.connect { }
    end
  end

  subject { described_class.new(mock_channel) }

  its(:topic_name) { should == MultipleMan.configuration.topic_name }

end
