module MultipleMan::Subscribers
  class Base

    def initialize(klass)
      self.klass = klass
    end

    attr_reader :klass

    def create(payload)
      # noop
    end

    def update(payload)
      # noop
    end

    def destroy(payload)
      # noop
    end

    def seed(payload)
      # noop
    end

    def routing_key(operation = :'#')
      MultipleMan::RoutingKey.new(klass, operation).to_s
    end

    def queue_name
      "#{MultipleMan.configuration.topic_name}.#{MultipleMan.configuration.app_name}.#{klass}"
    end

  private

    attr_writer :klass
  end
end
