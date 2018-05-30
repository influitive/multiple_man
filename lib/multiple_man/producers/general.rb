module MultipleMan
  module Producers
    class General
      def initialize
        @last_reset   = Time.now
      end

      def run_producer
        MultipleMan.logger.info "Starting producer"

        require_relative '../outbox/db'
        require_relative '../outbox/message/sequel'

        last_run = Time.now
        loop do
          timeout(last_run) unless @did_work
          Connection.connect { |connection| produce_all(connection) }
          reset! if should_reset?
          last_run = Time.now
        end
      end

      private

      # We are grouping by model because it allows us to reduce the amount of
      # confirms while still preserving the respective model messages ordering.
      # For example
      # [
      #   [ModelA_message_1, ModelA_message_2],
      #   [ModelB_message_1, ModelB_message_2]
      # ]
      # Allows us to:
      #
      # On iteration 1: published & confirm ModelA_message_1 and ModelB_message_1
      # On iteration 2: published & confirm ModelA_message_2 and ModelB_message_2
      # ...
      # iteration K: ModelA_message_K and ModelB_message_K are published & confirm
      # This will require at most K confirms where K is the largest amount of
      # messages / model. This is better than processing messages serially which
      # requires 1 confirm per message.
      def produce_all(connection)
        ActiveSupport::Notifications.instrument('multiple_man.producer.produce_all') do 
          @did_work = false
          Outbox::Message::Sequel.in_groups_and_delete(batch_size) do |messages|
            break if should_reset?

            grouped_messages = group_by_set(messages)

            while grouped_messages.any?
              @did_work = true
              sent_messages = send_messages!(grouped_messages, connection)
              confirm_published!(sent_messages, connection) if sent_messages
              remove_empty_lists!(grouped_messages)
            end
          end
        end
      end

      def should_reset?
        reset_time = MultipleMan.configuration.channel_reset_time
        reset_time && (Time.now - @last_reset) > reset_time
      end

      def reset!
        Connection.reset_channel!
        @last_reset = Time.now
      end

      def remove_empty_lists!(grouped_messages)
        grouped_messages.reject! { |m| m.empty? }
      end

      def send_messages!(grouped_messages, connection)
        ActiveSupport::Notifications.instrument('multiple_man.producer.send_messages') do
          grouped_messages.each_with_object([]) do |messages, sent_messages|
            next if messages.empty?

            # Temporarily we are going to get the current time from the db and attach it to the published message
            # This is strictly for diagnostics, and should probably be removed in production for performance reasons
            current_time = MultipleMan::Outbox::DB.connection.fetch('select current_timestamp;').first[:now]

            message = messages.delete_at(0)
            publish(connection, message, current_time)
            sent_messages << message
          end
        end
      end

      def confirm_published!(messages, connection)
        ActiveSupport::Notifications.instrument('multiple_man.producer.confirm_published') do
          channel = connection.channel
          begin
            retries ||= 3
            raise ProducerError.new(channel.nacked_set.to_a) unless channel.wait_for_confirms
          rescue ProducerError
            if (retries -= 1).zero?
              MultipleMan.logger.debug("Tried to publish #{messages.size}, but failed to publish #{channel.nacked_set.size} messages!")
              break
            end
            grouped_messages = group_by_set(messages)
            send_messages!(grouped_messages, connection)
            retry
          else
            MultipleMan.logger.debug("published #{messages.size} messages")
          end
        end
      end

      def group_by_set(messages)
        grouped_messages = Hash.new { |h, k| h[k] = [] }
        messages.each do |message|
          set_name = message[:set_name]
          grouped_messages[set_name] << message
        end
        grouped_messages.values
      end

      def publish(connection, message, publish_time)
        connection.topic.publish(
          message[:payload],
          routing_key: message[:routing_key],
          persistent:  true,
          headers:     { 
            db_created_at: message[:created_at].to_f,
            # Just for now... include the time we publish the message for diagnostic purposes
            published_at: publish_time.to_f
          }
        )
      end

      def timeout(last_run)
        sleep_time      = MultipleMan.configuration.producer_sleep_timeout
        time_since_last = Time.now - last_run
        sleep_time      = sleep_time - time_since_last

        sleep sleep_time if time_since_last < sleep_time
      end

      def batch_size
        MultipleMan.configuration.producer_batch_size
      end
    end
  end
end
