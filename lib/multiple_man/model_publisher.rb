require 'active_support/core_ext'

module MultipleMan
  class ModelPublisher

    def initialize(options = {})
      self.options = options.with_indifferent_access
    end

    def publish(records, operation=:create)
      return unless MultipleMan.configuration.enabled

      Connection.connect do |connection|
        all_records(records) do |record|
          push_record(connection, record, operation)
        end
      end
    end

  private

    attr_accessor :options

    def push_record(connection, record, operation)
      data = PayloadGenerator.new(record, operation, options)
      routing_key = RoutingKey.new(data.type, operation).to_s
      
      MultipleMan.logger.debug("  Record Data: #{data} | Routing Key: #{routing_key}")
      
      connection.topic.publish(data.payload, routing_key: routing_key)
    rescue Exception => ex
      MultipleMan.error(ex)
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
