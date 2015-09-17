module MultipleMan
  module Listener
    def Listener.included(base)
      base.extend(ClassMethods)
    end

    def routing_key(operation=self.operation)
      MultipleMan::RoutingKey.new(klass, operation).to_s
    end

    attr_accessor :klass
    attr_accessor :operation

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
        listener = self.new
        listener.klass = model
        listener.operation = operation
        Subscribers::Registry.register(listener)
      end
    end
  end
end
