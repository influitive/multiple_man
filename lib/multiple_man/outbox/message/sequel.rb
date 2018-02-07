module MultipleMan
  module Outbox
    module Message
      class Sequel < ::Sequel::Model(Outbox::DB.connection[:multiple_man_messages])
        def self.in_batches_and_delete(batch_size, &block)
          total   = count
          batches = (total / batch_size.to_f).ceil

          batches.times do
            messages = order(:id).limit(batch_size).to_a
            yield(messages)
            where(id: messages.map(&:id)).delete
          end
        end
      end
    end
  end
end
