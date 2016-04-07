module MultipleMan
  module Subscriber
    def Subscriber.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def subscribe(options = {})
        ::MultipleMan.configuration.register_listener(Subscribers::ModelSubscriber.new(self, options))
      end
    end
  end
end
