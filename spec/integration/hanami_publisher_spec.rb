require 'spec_helper'

describe "publishing at least once" do
  context 'at least once' do
    before(:each) do
      MultipleMan.configuration.messaging_mode = :at_least_once

      require 'hanami/model'
      require 'hanami/model/sql'

      setup_db

      class MMTestUserRepository < Hanami::Repository
        def create_with_message(args)
          transaction do
            create(args).multiple_man_publish(outbox: true)
          end
        end
      end

      class MMTestUser < Hanami::Entity
        include MultipleMan::Publisher

        publish fields: [:name]
      end

      Hanami::Model.configure do
        adapter :sql, MultipleMan.configuration.db_url
      end.load! rescue Hanami::Model::Error
    end

    after(:each) do
      clear_db

      Object.send(:remove_const, :MMTestUser)
      Object.send(:remove_const, :MMTestUserRepository)
    end

    let(:name) { SecureRandom.uuid }

    it 'publishes payload' do
      MMTestUserRepository.new.create_with_message(name: name)

      outbox_message = MultipleMan::Outbox::Adapter::MultipleManMessageRepository.new.last
      payload        = JSON.parse(outbox_message.payload)
      expect(payload['data']['name']).to eq(name)

      expect(MMTestUserRepository.new.all.count).to eq(1)
      expect(MultipleMan::Outbox::Adapter::MultipleManMessageRepository.new.all.count).to eq(1)
    end

    it 'guarantees publishing within a transaction' do
      expect(MultipleMan::Outbox::Adapter::MultipleManMessageRepository)
        .to receive(:push_record).and_raise('MessageSaveError')

        expect {
          MMTestUserRepository.new.create_with_message(name: name)
        }.to raise_error(MultipleMan::ProducerError)

      expect(MMTestUserRepository.new.all.count).to eq(0)
      expect(MultipleMan::Outbox::Adapter::MultipleManMessageRepository.new.all.count).to eq(0)
    end
  end
end
