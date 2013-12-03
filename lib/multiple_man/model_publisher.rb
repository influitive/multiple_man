module MultipleMan
  class ModelPublisher

    def initialize(operation, options = {})
      self.operation = operation
      self.options = options
    end

    def after_commit(record)
      Connection.connect do |connection|
        connection.topic.publish(record_data(record), routing_key: RoutingKey.new(record, operation).to_s)
      end
    end

  private

    attr_accessor :operation, :options

    def connection
      @connection ||= Connection.new
    end

    def record_data(record)
      AttributeExtractor.new(record, fields).to_json
    end

    def fields
      options[:fields]
    end

    
  end
end