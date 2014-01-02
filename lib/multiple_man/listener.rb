require 'json'
require 'active_support/core_ext/hash'

module MultipleMan
  class Listener

    class << self
      def start(connection)
        MultipleMan.logger.info "Starting listeners."
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
      MultipleMan.logger.info "Listening for #{subscription.klass} with routing key #{subscription.routing_key}."
      queue.bind(connection.topic, routing_key: subscription.routing_key).subscribe do |delivery_info, meta_data, payload|
        process_message(delivery_info, payload)
      end
    end

    def process_message(delivery_info, payload)
      MultipleMan.logger.info "Processing message for #{delivery_info.routing_key}."
      begin
        operation = delivery_info.routing_key.split(".").last
        subscription.send(operation, JSON.parse(payload).with_indifferent_access)
      rescue Exception => ex
        MultipleMan.logger.error "   Error - #{ex.message}"
      else
        MultipleMan.logger.info "   Successfully processed!"
      end
    end

    def queue
      connection.channel.queue(subscription.queue_name, durable: true, auto_delete: false)
    end

  private

    def connection
      self.class.connection
    end

  end
end