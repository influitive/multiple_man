module MultipleMan::Subscribers
  class Registry
    attr_reader :subscriptions

    def initialize
      @subscriptions = []
    end

    def register(subscription)
      self.subscriptions << subscription
    end
  end
end
