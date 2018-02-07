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
      expect(producer).to receive(:loop).and_yield
      create_messages(messages)

      producer.run_producer

      tr = Thread.new {
        require 'multiple_man'
        configure_multiple_man
        consumer.run
      }
      wait_for { MultipleMan::Outbox.count == 0 && Inbox.all.count == messages }
      tr.kill

      expect(Inbox.all.count).to eq(messages)
      expect(Inbox.all.uniq.count).to eq(messages)
    end
  end
end
