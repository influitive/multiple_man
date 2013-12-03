module MultipleMan
  class ModelSubscriber

    @subscriptions = []
    class << self
      attr_accessor :subscriptions

      def register(klass)
        self.subscriptions << klass
      end
    end
  end
end