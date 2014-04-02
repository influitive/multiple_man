require 'json'
require 'active_support/core_ext/hash'

module MultipleMan
  class Listener

    class << self
      def start(connection)
        MultipleMan.logger.debug "Starting listeners."
        self.connection = connection
        MultipleMan.logger.debug Subscribers::Registry.subscriptions.to_json

        Subscribers::Registry.subscriptions.each do |subscription|
          new(subscription).listen
        end
      end

      attr_accessor :connection
    end

    delegate :queue_name, to: :subscription

    def initialize(subscription)
      self.subscription = subscription
    end

    attr_accessor :subscription

    def listen
      MultipleMan.logger.info "Listening for #{subscription.klass} with routing key #{routing_key}."
      queue.bind(connection.topic, routing_key: routing_key).subscribe(ack: true) do |delivery_info, meta_data, payload|
        process_message(delivery_info, payload)
      end
    end

    def process_message(delivery_info, payload)
      MultipleMan.logger.info "Processing message for #{delivery_info.routing_key}."
      begin
        subscription.send(operation(delivery_info), JSON.parse(payload).with_indifferent_access)
      rescue Exception => ex
        MultipleMan.logger.error "   Error - #{ex.message}\n\n#{ex.backtrace}"
        MultipleMan.error(ex)
      else
        MultipleMan.logger.debug "   Successfully processed!"
        queue.channel.acknowledge(delivery_info.delivery_tag, false)
      end
    end

    def operation(delivery_info)
      delivery_info.routing_key.split(".").last
    end

    def queue
      connection.queue(queue_name, durable: true, auto_delete: false)
    end

    def routing_key
      subscription.routing_key
    end

  private

    def connection
      self.class.connection
    end

  end
end
