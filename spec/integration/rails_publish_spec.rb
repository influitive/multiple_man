require 'spec_helper'

describe "publishing at least once" do
  context 'at least once' do
    before(:each) do
      MultipleMan.configuration.messaging_mode = :at_least_once

      setup_db
      setup_rails

      class MMTestUser < ::ActiveRecord::Base
        include MultipleMan::Publisher

        publish fields: [:name]
      end
    end

    after(:each) do
      clear_db

      Object.send(:remove_const, :MMTestUser)
    end

    let(:name) { SecureRandom.uuid }
    let(:expeted_payload) {
      {
        "type"      => "MMTestUser",
        "operation" => "create",
        "id"        => { "id" => 1 },
        "data"      => { "name" => name }
      }
    }

    it 'publishes payload on create' do
      MMTestUser.create!(name: name)

      expect(MMTestUser.count).to eq(1)
      expect(MultipleMan::Outbox.count).to eq(1)

      outbox_message = MultipleMan::Outbox::Message::Rails.last
      payload        = JSON.parse(outbox_message.payload)
      expect(payload).to eq(expeted_payload)
    end

    it 'publishes after touch' do
      user = MMTestUser.create!(name: name)
      expect(MultipleMan::Outbox.count).to eq(1)

      user.touch
      expect(MultipleMan::Outbox.count).to eq(2)
    end

    it 'publishes payload when calling multiple_man_publish directly' do
      user = MMTestUser.create!(name: name)
      expect(MultipleMan::Outbox.count).to eq(1)

      expect{user.multiple_man_publish}
        .to change{MultipleMan::Outbox.count}.by(1)
    end

    it 'publishes payload for CUD' do
      user = MMTestUser.create!(name: name)
      user.name = SecureRandom.uuid
      user.save!
      user.destroy!

      expect(MMTestUser.count).to eq(0)
      expect(MultipleMan::Outbox.count).to eq(3)

      payloads = MultipleMan::Outbox::Message::Rails.pluck(:payload)
      payloads = payloads.map { |pl| JSON.parse(pl) }

      operations = payloads.map { |pl| pl['operation'] }
      expect(operations).to eq(["create", "update", "destroy"])
    end

    it 'guarantees publishing within a transaction' do
      expect(MultipleMan::Outbox::Message::Rails)
        .to receive(:push_record).and_raise(MultipleMan::ProducerError)

        expect {
          MMTestUser.new(name: name).save!
        }.to raise_error(MultipleMan::ProducerError)

      expect(MMTestUser.count).to eq(0)
      expect(MultipleMan::Outbox.count).to eq(0)
    end
  end

  context 'at most once' do
    before(:each) do
      MultipleMan.configuration.messaging_mode = :at_most_once

      setup_db
      setup_rails

      class MMTestUser < ::ActiveRecord::Base
        include MultipleMan::Publisher

        publish fields: [:name]
      end
    end

    after(:each) do
      clear_db

      Object.send(:remove_const, :MMTestUser)
    end

    it 'publishes on after-commit' do
      MultipleMan::Connection.connect do |connection|
        expect(connection.topic).to receive(:publish).and_raise('BunnyError')
      end

      MMTestUser.new(name: 'name').save!

      expect(MMTestUser.count).to eq(1)
    end

    it 'publishes to outbox when calling multiple_man_publish directly' do
      user = MMTestUser.create!(name: 'name')
      expect(MultipleMan::Outbox.count).to eq(0)

      expect{user.multiple_man_publish}
        .to change{MultipleMan::Outbox.count}.by(0)
    end
  end

  context 'outbox alpha' do
    before(:each) do
      MultipleMan.configuration.messaging_mode = :outbox_alpha

      setup_db
      setup_rails

      class MMTestUser < ::ActiveRecord::Base
        include MultipleMan::Publisher

        publish fields: [:name]
      end
    end

    after(:each) do
      clear_db

      Object.send(:remove_const, :MMTestUser)
    end

    it 'publishes twice' do
      MultipleMan::Connection.connect do |connection|
        expect(connection.topic).to receive(:publish)
      end

      MMTestUser.new(name: 'name').save!

      expect(MMTestUser.count).to eq(1)

      routing_key = MultipleMan::Outbox::Message::Rails.last.routing_key
      expect(routing_key).to eq('multiple_man.MMTestUser.create')
    end

    it 'publishes payload when calling multiple_man_publish directly' do
      user = MMTestUser.create!(name: 'name')
      expect(MultipleMan::Outbox.count).to eq(1)

      expect{user.multiple_man_publish}
        .to change{MultipleMan::Outbox.count}.by(1)
    end
  end
end
