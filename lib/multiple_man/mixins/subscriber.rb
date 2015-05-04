module MultipleMan
  module Subscriber
    def Subscriber.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def subscribe(options = {})
        Subscribers::Registry.register(Subscribers::ModelSubscriber.new(self.to_s, options))
      end
    end
  end
end
