module MultipleMan
  class ModelPublisher

    def initialize(options = {})
      self.options = options
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
      data = record_data(record)
      routing_key = RoutingKey.new(record_type(record), operation).to_s
      MultipleMan.logger.debug("  Record Data: #{data} | Routing Key: #{routing_key}")
      connection.topic.publish(data, routing_key: routing_key)
    rescue Exception => ex
      MultipleMan.error(ex)
    end

    def all_records(records, &block)
      if records.respond_to?(:find_each)
        records.find_each(&block)
      elsif records.respond_to?(:each)
        records.each(&block)
      else
        yield records
      end
    end


    def record_type(record)
      options[:as] || record.class.name
    end

    def record_data(record)
      {
        id: Identity.build(record, options).value,
        data: serializer(record).as_json
      }.to_json
    end

    # Todo - can we unify the constructor for serializers
    # and attribute extractors and simplify this?
    def serializer(record)
      if options[:with]
        options[:with].new(record)
      else
        AttributeExtractor.new(record, fields)
      end
    end

    def fields
      options[:fields]
    end

    def identifier
      options[:identifier]
    end

  end
end
