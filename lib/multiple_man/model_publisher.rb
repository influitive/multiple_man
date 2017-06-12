require 'active_support/core_ext'

module MultipleMan
  class ModelPublisher

    def initialize(options = {})
      self.options = options.with_indifferent_access
    end

    def publish(records, operation=:create)
      return unless MultipleMan.configuration.enabled

      Connection.connect do |connection|
        ActiveSupport::Notifications.instrument('multiple_man.publish_messages') do
          all_records(records) do |record|
            ActiveSupport::Notifications.instrument('multiple_man.publish_message') do
              push_record(connection, record, operation)
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

      publish_confirmed?(connection, data) if MultipleMan.configuration.publisher_confirms
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

    def publish_confirmed?(connection, data)
      return true if connection.topic.wait_for_confirms

      err = ProducerError.new(reason: 'wait_for_confirms', payload: data.payload)
      MultipleMan.error(err, reraise: false)
    end
  end
end
