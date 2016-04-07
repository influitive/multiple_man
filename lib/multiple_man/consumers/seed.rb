module MultipleMan::Consumers
  class Seed < General

    private

    def operation(_, _)
      "create"
    end

    def routing_key_for_subscriber(subscriber)
      subscriber.routing_key(:seed)
    end

  end
end
