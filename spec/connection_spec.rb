require 'spec_helper'

describe MultipleMan::Connection do

  let(:mock_bunny) { double(Bunny) }
  let(:mock_channel) { double(Bunny::Channel) }

  describe "connect" do
    it "should open and close the connection" do
      mock_bunny.should_receive(:start)
      Bunny.should_receive(:new).and_return(mock_bunny)
      mock_bunny.should_receive(:create_channel).and_return(mock_channel)
      mock_channel.should_receive(:close)

      described_class.connect
    end
  end

  subject { described_class.new(mock_bunny) }

  its(:topic_name) { should == MultipleMan.configuration.topic_name }

end