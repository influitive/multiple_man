module MultipleMan::Subscribers
  class Base

    def initialize(klass)
      self.klass = klass
    end

    attr_reader :klass

    def create(_)
      # noop
    end

    def update(_)
      # noop
    end

    def destroy(_)
      # noop
    end

    def seed(_)
      # noop
    end

    def routing_key(operation = :'#')
      MultipleMan::RoutingKey.new(klass, operation).to_s
    end

    def listen_to
      klass
    end

    private

    attr_writer :klass
  end
end
