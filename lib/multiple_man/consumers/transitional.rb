require 'json'
require 'active_support/core_ext/hash'

module MultipleMan::Consumers
  class Transitional

    attr_reader :subscription, :queue, :topic

    def initialize(subscription:, queue:, topic:)
      @subscription = subscription
      @topic = topic
      @queue = queue
    end

    def listen
      MultipleMan.logger.info "Listening for #{subscription.listen_to} with routing key #{routing_key}."
      queue.unbind(topic, routing_key: routing_key).subscribe(manual_ack: true) do |delivery_info, _, payload|
        process_message(delivery_info, payload)
      end
    end

    def process_message(delivery_info, payload)
      MultipleMan.logger.info "Processing message for #{delivery_info.routing_key}."

      payload = JSON.parse(payload).with_indifferent_access
      subscription.send(operation(delivery_info, payload), payload)
      MultipleMan.logger.debug "   Successfully processed!"
      queue.channel.acknowledge(delivery_info.delivery_tag, false)
    rescue => ex
      handle_error(ex, delivery_info)
    end

    def handle_error(ex, delivery_info)
      MultipleMan.logger.error "   Error - #{ex.message}\n\n#{ex.backtrace}"
      MultipleMan.error(ex, reraise: false)

      # Requeue the message
      queue.channel.nack(delivery_info.delivery_tag)
    end

    def operation(delivery_info, payload)
      payload['operation'] || delivery_info.routing_key.split(".").last
    end

    def routing_key
      subscription.routing_key
    end

  end
end
