module MultipleMan
  class SeederListener < Listener
    def routing_key
      subscription.routing_key(:seed)
    end

    # seeds should only ever be a create
    def operation(delivery_info)
      "create"
    end
  end
end
