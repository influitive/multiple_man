require 'spec_helper'

describe MultipleMan::Producers::General do
  context '#produce' do
    let(:subject) { described_class.new }

    before(:each) do
      setup_db

      require 'rails'
      require 'active_record'

      conn = { adapter: "postgresql", database: "postgres" }
      ActiveRecord::Base.establish_connection(conn)
    end

    after(:each) { clear_db }

    it '#run_producer runs producer' do
      old_time = Time.now - 100_000
      message  = {
        routing_key: 'Foo.bar',
        payload:     'foo',
        created_at:  old_time,
        updated_at:  old_time
      }

      MultipleMan.configuration.messaging_mode = :at_least_once
      MultipleMan::Connection.connect do |connection|
        expect(connection.topic).to receive(:publish).with(
          'foo',
          {
            routing_key: message[:routing_key],
            persistent: true,
            headers: { published_at: old_time.to_i }
          }
        )
      end
      expect(subject).to receive(:loop).and_yield
      insert_message(message)

      subject.run_producer

      expect(MultipleMan::Outbox.count).to eq(0)
    end

    it '#run_producer raises when wait_for_confirms fails' do
      MultipleMan.configuration.messaging_mode = :at_least_once
      MultipleMan::Connection.connect do |connection|
        expect(connection.channel).to receive(:wait_for_confirms).and_return(false)
      end
      expect(subject).to receive(:loop).and_yield
      create_messages(1)

      expect {
        subject.run_producer
      }.to raise_error(MultipleMan::ProducerError)
    end

    it '#run_producer does not hammer db' do
      MultipleMan.configuration.messaging_mode = :at_least_once
      expect(subject).to receive(:loop).and_yield
      st = Time.now

      subject.run_producer

      et = Time.now
      (et - st).should be >= MultipleMan.configuration.producer_sleep_timeout
    end

    context 'channel_reset' do
      after(:each) { MultipleMan.configuration.channel_reset_time = nil }

      it 'does not reset channel' do
        expect(subject).to receive(:loop).and_yield

        create_messages(1)
        expect(MultipleMan::Connection).to_not receive(:reset_channel!)
        subject.run_producer
      end

      it 'resets channel' do
        MultipleMan.configuration.channel_reset_time = 0
        expect(subject).to receive(:loop).and_yield

        create_messages(1)
        expect(MultipleMan::Connection).to receive(:reset_channel!)
        subject.run_producer
      end
    end
  end
end
