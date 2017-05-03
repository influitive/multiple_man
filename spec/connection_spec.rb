require 'spec_helper'

describe MultipleMan::Connection do

  let(:mock_bunny) { double(Bunny, open?: true, close: nil) }
  let(:mock_channel) { double(Bunny::Channel, close: nil, open?: true, topic: nil, number: 1) }

  after do
    Thread.current.thread_variable_set(:multiple_man_current_channel, nil)
    MultipleMan::Connection.reset!
  end

  it "should open a connection and a channel with opts" do
    MultipleMan.configuration.exchange_opts = {durable: true, another: 'opt'}

    MultipleMan::Connection.should_receive(:connection).and_return(mock_bunny)
    mock_bunny.should_receive(:create_channel).once.and_return(mock_channel)
    expect(mock_channel).to receive(:topic).with(MultipleMan.configuration.topic_name, durable: true, another: 'opt')

    described_class.connect { }
  end
end
