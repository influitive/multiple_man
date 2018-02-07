module MultipleMan
  module Outbox
    module MessageAdapter
      module_function

      def adapter
        if defined?(Rails)
          require_relative 'message/rails'
          Outbox::Message::Rails
        else
          raise 'NoOutboxAdapter'
        end
      end

      def count
        adapter.count
      end
    end
  end
end
