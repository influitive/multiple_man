module MultipleMan
  module Outbox
    module Adapters
      class General < ::Sequel::Model(Outbox::DB.connection[:multiple_man_messages])
      end
    end
  end
end
