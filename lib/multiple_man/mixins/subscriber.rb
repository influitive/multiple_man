module MultipleMan
  module Subscriber
    def Subscriber.included(base)
      MultipleMan::ModelSubscriber.register(base)
    end
  end
end