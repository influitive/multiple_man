module MultipleMan::Listeners
  class SeederListener < Listener
    def routing_key
      subscription.routing_key(:seed)
    end

    # seeds should only ever be a create
    def operation(_, _)
      "create"
    end

    def queue
      connection.queue(subscription.queue_name + ".seed", auto_delete: true)
    end
  end
end
