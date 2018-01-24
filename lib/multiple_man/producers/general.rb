module MultipleMan
  module Producers
    class General
      SLEEP_TIMEOUT = 2
      BATCH_SIZE    = 1000.0

      def run_producer
        MultipleMan.logger.info "Starting producer"

        require_relative '../outbox/db'
        require_relative '../outbox/adapters/general'

        last_run = Time.now
        loop do
          timeout(last_run)
          Connection.connect { |connection| produce_all(connection) }
          last_run = Time.now
        end
      end

      private

      def produce_all(connection)
        count   = Outbox::Adapters::General.count
        batches = (count / BATCH_SIZE).ceil

        batches.times do
          messages = Outbox::Adapters::General.order(:id).limit(BATCH_SIZE).to_a

          grouped_messages = group_by_routing_key(messages)
          longest_group    = grouped_messages.map(&:size).max

          longest_group.times do
            sent_messages = send_messages!(grouped_messages, connection)
            confirm_published!(sent_messages, connection) if sent_messages
          end
        end
      end

      def send_messages!(grouped_messages, connection)
        grouped_messages.each_with_object([]) do |messages, sent_messages|
          next if messages.empty?

          message = messages.slice!(0)
          publish(connection, message)
          sent_messages << message
        end
      end

      def confirm_published!(messages, connection)
        channel = connection.channel
        raise ProducerError.new(channel.nacked_set.to_a) unless channel.wait_for_confirms

        Outbox::Adapters::General.where(id: messages.map(&:id)).delete
      end

      def group_by_routing_key(messages)
        grouped_messages = Hash.new { |h, k| h[k] = [] }
        messages.each do |message|
          ordering_key = RoutingKey.ordering_key(message.routing_key)
          grouped_messages[ordering_key] << message
        end
        grouped_messages.values
      end

      def publish(connection, message)
        connection.topic.publish(
          message.values[:payload],
          routing_key: message.values[:routing_key],
          persistent:  true,
          headers:     { published_at: Time.now.to_i }
        )
      end

      def clear_message(message, channel)
        raise ProducerError.new(channel.nacked_set.to_a) unless channel.wait_for_confirms

        message.destroy
        MultipleMan.logger.debug(
          "Record Data: #{message.values[:payload]} | Routing Key: #{message.values[:routing_key]}"
        )
      end

      def timeout(last_run)
        time_since_last = Time.now - last_run
        sleep_time      = SLEEP_TIMEOUT - time_since_last

        sleep sleep_time if time_since_last < SLEEP_TIMEOUT
      end
    end
  end
end
