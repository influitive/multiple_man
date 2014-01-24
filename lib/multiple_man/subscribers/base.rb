module MultipleMan::Subscribers
  class Base

    def initialize(klass)
      self.klass = klass
    end

    attr_reader :klass

    def create
      # noop
    end

    def update
      # noop
    end

    def destroy
      # noop
    end

    def routing_key
      MultipleMan::RoutingKey.new(klass).to_s
    end

    def queue_name
      "#{MultipleMan.configuration.topic_name}.#{MultipleMan.configuration.app_name}.#{klass.name}"
    end

  private

    attr_writer :klass
  end
end