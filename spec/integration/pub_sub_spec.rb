require 'spec_helper'

describe 'pub_sub' do
  context '#produce' do
    let(:producer) { MultipleMan::Producers::General.new }
    let(:consumer) { MultipleMan::Runner.new }
    let(:messages) { 100 }

    before(:each) do
      setup_db
      setup_rails

      class Inbox
        @@all = []

        def self.all
          @@all
        end

        def self.<<(i)
          @@all << i
        end

        def self.reset!
          @@all = []
        end
      end

      class ListenerClass
        include MultipleMan::Listener

        listener_klasses.each { |klass| listen_to(klass) }

        def create(payload)
          Inbox.all << payload['counter']
        end
      end
    end

    after(:each) { clear_db }

    it '#pub_sub' do
      allow(consumer).to receive(:preload_framework!).and_return(true)
      MultipleMan.configuration.messaging_mode = :at_least_once
      create_messages(messages)

      producer_thread = Thread.new {
        producer.run_producer
      }

      consumer_thread = Thread.new {
        require 'multiple_man'
        configure_multiple_man
        consumer.run
      }
      wait_for { MultipleMan::Outbox.count == 0 && Inbox.all.count == messages }
      producer_thread.kill && consumer_thread.kill

      expect(Inbox.all.count).to eq(messages)
      expect(Inbox.all.uniq.count).to eq(messages)
    end

    context 'with channel reset' do
      before(:each) { MultipleMan.configuration.channel_reset_time = 0 }
      after(:each) { MultipleMan.configuration.channel_reset_time = nil }

      it '#pub_sub' do
        allow(consumer).to receive(:preload_framework!).and_return(true)
        MultipleMan.configuration.messaging_mode = :at_least_once
        create_messages(messages)

        producer_thread = Thread.new {
          producer.run_producer
        }

        consumer_thread = Thread.new {
          require 'multiple_man'
          configure_multiple_man
          consumer.run
        }

        wait_for { MultipleMan::Outbox.count == 0 && Inbox.all.count == messages }
        producer_thread.kill && consumer_thread.kill

        expect(Inbox.all.count).to eq(messages)
        expect(Inbox.all.uniq.count).to eq(messages)
      end
    end
  end
end
