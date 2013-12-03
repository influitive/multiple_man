require 'spec_helper'

describe MultipleMan::Connection do

  let(:mock_bunny) { double(Bunny) }

  describe "connect" do
    it "should open and close the connection" do
      mock_bunny.should_receive(:start)
      mock_bunny.should_receive(:close)
      Bunny.should_receive(:new).and_return(mock_bunny)
      
      described_class.connect
    end
  end

  subject { described_class.new(mock_bunny) }

  its(:topic_name) { should == MultipleMan.configuration.topic_name }

end