module MultipleMan
  module Subscriber
    def Subscriber.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def subscribe(options)
        MultipleMan::ModelSubscriber.register(self, options)
      end
    end
  end
end