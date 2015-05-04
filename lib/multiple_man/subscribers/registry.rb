module MultipleMan::Subscribers
  class Registry
    @subscriptions = []
    class << self
      attr_accessor :subscriptions

      def register(subscription)
        self.subscriptions << subscription
      end
    end
  end
end
