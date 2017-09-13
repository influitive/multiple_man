require 'spec_helper'

describe MultipleMan::Connection do
  let(:opts) { { durable: true, another: 'opt' } }

  before do
    MultipleMan.configuration.exchange_opts = opts
  end

  it '#channel_pool configures pool' do
    expect_any_instance_of(Bunny::Channel).to receive(:topic).with('multiple_man', opts)
    channel_pool = MultipleMan::Connection.channel_pool

    channel_pool.with do |ch|
      expect(ch.class).to eq(Bunny::Channel)
    end
  end

  it '#close closes connection and allows new channel_pool' do
    expect_any_instance_of(Bunny::Session).to receive(:close)

    channel_pool = MultipleMan::Connection.channel_pool
    channel_pool.with { |_| puts 'pool is lazy loaded' }
    MultipleMan::Connection.close

    expect(Bunny).to receive(:new).and_call_original

    channel_pool = MultipleMan::Connection.channel_pool
    channel_pool.with { |_| puts 'pool is lazy loaded' }
  end
end
