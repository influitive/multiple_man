require 'json'

module MultipleMan
  class Listener

    class << self
      def start(connection)
        self.connection = connection
        ModelSubscriber.subscriptions.each do |subscription|
          new(subscription).listen
        end
      end

      attr_accessor :connection
    end

    def initialize(subscription)
      self.subscription = subscription
    end

    attr_accessor :subscription

    def listen
      queue.bind(connection.topic, routing_key: subscription.routing_key) do |delivery_info, meta_data, payload|
        process_message(delivery_info, payload)
      end
    end

    def process_message(delivery_info, payload)
      operation = delivery_info.routing_key.split(".").last
      subscription.send(operation, JSON.parse(payload))
    end

    def queue
      connection.channel.queue("", exclusive: true)
    end

  private

    def connection
      self.class.connection
    end

  end
end