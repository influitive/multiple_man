module MultipleMan
  module Tracers
    class NullTracer
      def initialize(subscriber)
        @subscriber = subscriber
      end

      def handle(delivery_info, meta_data, message, method)
        @subscriber.send(method, message)
      end
    end
  end
end
