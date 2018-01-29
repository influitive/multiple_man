require 'active_support/core_ext'

module MultipleMan
  class ModelPublisher

    def initialize(options = {})
      self.options = options.with_indifferent_access
      @message_publisher = Outbox::MessageAdapter.adapter if MultipleMan.configuration.at_least_once?
    end

    def publish(records, operation = :create, outbox: false)
      return unless MultipleMan.configuration.enabled

      Connection.connect do |connection|
        ActiveSupport::Notifications.instrument('multiple_man.publish_messages') do
          all_records(records) do |record|
            ActiveSupport::Notifications.instrument('multiple_man.publish_message') do
              if outbox && @message_publisher
                @message_publisher.push_record(record, operation, options)
              else
                push_record(connection, record, operation)
              end
            end
          end
        end
      end
    rescue Exception => ex
      err = ProducerError.new(reason: ex, payload: records.inspect)
      MultipleMan.error(err, reraise: false)
    end

    private

    attr_accessor :options

    def push_record(connection, record, operation)
      data = PayloadGenerator.new(record, operation, options)
      routing_key = RoutingKey.new(data.type, operation).to_s

      MultipleMan.logger.debug("  Record Data: #{data} | Routing Key: #{routing_key}")

      connection.topic.publish(data.payload, routing_key: routing_key)
    end

    def all_records(records, &block)
      if records.respond_to?(:find_each)
        records.find_each(batch_size: 100, &block)
      elsif records.respond_to?(:each)
        records.each(&block)
      else
        yield records
      end
    end
  end
end
