require 'json'
require 'active_support/core_ext/hash'

module MultipleMan
  module Consumers
    class General
      def initialize(subscribers:, queue:, topic:)
        self.subscribers = subscribers
        @topic = topic
        @queue = queue
      end

      def listen
        MultipleMan.logger.debug "Starting listeners."
        create_bindings

        queue.subscribe(manual_ack: true) do |delivery_info, meta_data, payload|
          MultipleMan.logger.info "Processing message for #{delivery_info.routing_key}."
          message = JSON.parse(payload).with_indifferent_access
          receive(delivery_info, meta_data, message)
        end
      end

      private

      attr_reader :subscribers, :topic, :queue

      def create_bindings
        subscribers.values.each do |subscriber|
          MultipleMan.logger.info "Listening for #{subscriber.listen_to} with routing key #{subscriber.routing_key}."
          queue.bind(topic, routing_key: routing_key_for_subscriber(subscriber))
        end
      end

      def receive(delivery_info, _, message)
        method = operation(message, delivery_info.routing_key)
        dispatch_subscribers(message, method, delivery_info.routing_key)
        queue.channel.acknowledge(delivery_info.delivery_tag, false)

        MultipleMan.logger.info "Successfully processed! #{delivery_info.routing_key}"
      rescue => ex
        MultipleMan.logger.debug "\tError #{ex.message} \n#{ex.backtrace}"
        MultipleMan.error(ex, reraise: false, payload: message, delivery_info: delivery_info)
        queue.channel.nack(delivery_info.delivery_tag)
      end

      def dispatch_subscribers(message, method, routing_key)
        subscribers.select { |k,s| k.match(routing_key) }
          .values
          .each do |s|
            s.send(method, message)
          end
      end

      def operation(message, routing_key)
        message['operation'] || routing_key.split('.').last
      end

      def routing_key_for_subscriber(subscriber)
        subscriber.routing_key
      end

      def subscribers=(subscribers)
        @subscribers = subscribers.map { |s|
          key = routing_key_for_subscriber(s).gsub('.', '\.').gsub('#', '.*')
          [/^#{key}$/, s]
        }.to_h
      end
    end
  end
end
