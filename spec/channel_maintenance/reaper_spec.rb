require 'spec_helper'

describe MultipleMan::ChannelMaintenance::Reaper do
  let(:mock_channel) { double(Bunny::Channel, close: nil, closed?: false, number: 1) }
  let(:mock_queue) { double(Queue, pop: mock_channel) }
  let(:mock_config_hash) { { time_between_retries: 1 } }
  let(:mock_mm_config) { double(MultipleMan, connection_recovery: mock_config_hash) }

  before do
    expect(Queue).to receive(:new).and_return(mock_queue)
    expect(Thread).to receive(:new).and_yield
    expect_any_instance_of(
      MultipleMan::ChannelMaintenance::Reaper
    ).to receive(:loop).and_yield
  end

  it "reaps an open connection" do
    expect(mock_channel).to receive(:close)

    described_class.new(mock_mm_config)
  end

  it "raises errors" do
    expect(mock_channel).to receive(:closed?).and_raise(NoMethodError)

    expect { described_class.new(mock_mm_config) }.to raise_error(NoMethodError)
  end
end
