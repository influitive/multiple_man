module MultipleMan
  module Listener
    def Listener.included(base)
      base.extend(ClassMethods)
    end

    def routing_key
      MultipleMan::RoutingKey.new(klass, operation).to_s
    end

    attr_accessor :klass
    attr_accessor :operation

    def create
      # noop
    end

    def update
      # noop
    end

    def destroy
      # noop
    end

    def seed
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
