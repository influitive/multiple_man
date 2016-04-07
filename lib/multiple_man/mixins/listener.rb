module MultipleMan
  module Listener
    def self.included(base)
      base.extend(ClassMethods)
    end

    def routing_key(operation = self.operation)
      MultipleMan::RoutingKey.new(listen_to, operation).to_s
    end

    def klass
      self.class.name
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

    def queue_name
      "#{MultipleMan.configuration.topic_name}.#{MultipleMan.configuration.app_name}.#{klass}"
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
