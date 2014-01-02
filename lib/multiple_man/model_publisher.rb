module MultipleMan
  class ModelPublisher

    def initialize(operation, options = {})
      self.operation = operation
      self.options = options
    end

    def after_commit(record)
      return unless MultipleMan.configuration.enabled

      MultipleMan.logger.info("Publishing #{record}")
      Connection.connect do |connection|
        push_record(connection, record)
      end
    end

  private

    attr_accessor :operation, :options

    def push_record(connection, record)
      data = record_data(record)
      routing_key = RoutingKey.new(record, operation).to_s
      MultipleMan.logger.info("  Record Data: #{data} | Routing Key: #{routing_key}")
      connection.topic.publish(data, routing_key: routing_key)
    end

    def record_data(record)
      AttributeExtractor.new(record, fields, identifier).to_json
    end

    def fields
      options[:fields]
    end

    def identifier
      options[:identifier]
    end
    
  end
end