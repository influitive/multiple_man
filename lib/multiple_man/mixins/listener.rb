module MultipleMan
  module Listener
    def Listener.included(base)
      base.extend(ClassMethods)
    end

    def routing_key(operation=self.operation)
      MultipleMan::RoutingKey.new(listen_to, operation).to_s
    end

    def klass
      self.class.name
    end
    attr_accessor :operation
    attr_accessor :listen_to

    def create(_)
      # noop
    end

    def update(_)
      # noop
    end

    def destroy(_)
      # noop
    end

    def queue_name
      "#{MultipleMan.configuration.topic_name}.#{MultipleMan.configuration.app_name}.#{klass}"
    end

    module ClassMethods
      def listen_to(model, operation: '#')
        listener = self.new
        listener.listen_to = model
        listener.operation = operation
        Subscribers::Registry.register(listener)
        listener
      end
    end
  end
end
