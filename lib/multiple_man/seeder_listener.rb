module MultipleMan
  class SeederListener < Listener
    def routing_key
      subscription.routing_key(:seed)
    end
  end
end
