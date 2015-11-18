require 'json'
require 'active_support/core_ext/hash'

module MultipleMan::Listeners
  class Listener

    class << self
      def start
        MultipleMan.logger.debug "Starting listeners."

        MultipleMan::Subscribers::Registry.subscriptions.each do |subscription|
          new(subscription).listen
        end
      end
    end

    delegate :queue_name, to: :subscription

    def initialize(subscription)
      self.subscription = subscription
      self.init_connection
    end

    def init_connection
      connection = Bunny.new(MultipleMan.configuration.connection)
      connection.start
      channel = connection.create_channel(nil, MultipleMan.configuration.worker_concurrency)
      channel.prefetch(100)
      self.connection = MultipleMan::Connection.new(channel)
    end

    attr_accessor :subscription, :connection

    def listen

      MultipleMan.logger.info "Listening for #{subscription.klass} with routing key #{routing_key}."
      queue.bind(connection.topic, routing_key: routing_key).subscribe(ack: true) do |delivery_info, _, payload|
        process_message(delivery_info, payload)
      end
    end

    def process_message(delivery_info, payload)
      MultipleMan.logger.info "Processing message for #{delivery_info.routing_key}."
      begin
        payload = JSON.parse(payload).with_indifferent_access
        subscription.send(operation(delivery_info, payload), payload)
      rescue ex
        handle_error(ex, delivery_info)
      else
        MultipleMan.logger.debug "   Successfully processed!"
        queue.channel.acknowledge(delivery_info.delivery_tag, false)
      end
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

    def queue
      connection.queue(queue_name, durable: true, auto_delete: false)
    end

    def routing_key
      subscription.routing_key
    end

  end
end
