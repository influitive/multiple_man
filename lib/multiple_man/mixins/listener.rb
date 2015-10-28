module MultipleMan
  module Listener
    def self.included(base)
      base.extend(ClassMethods)
    end

    def routing_key(operation = self.operation)
      MultipleMan::RoutingKey.new(listen_to, operation).to_s
    end

    attr_accessor :operation
    attr_accessor :listen_to

    def create(payload)
      # noop
    end

    def update(payload)
      # noop
    end

    def destroy(payload)
      # noop
    end

    module ClassMethods
      def listen_to(model, operation: '#')
        listener = new
        listener.listen_to = model
        listener.operation = operation
        MultipleMan.configuration.register_listener(listener)
        listener
      end
    end
  end
end
