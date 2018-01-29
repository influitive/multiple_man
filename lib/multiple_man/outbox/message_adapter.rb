module MultipleMan
  module Outbox
    module MessageAdapter
      module_function

      def adapter
        if defined?(Rails)
          require_relative 'adapters/rails'
          Outbox::Adapter::Rails
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
