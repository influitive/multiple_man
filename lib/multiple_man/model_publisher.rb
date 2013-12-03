module MultipleMan
  class ModelPublisher

    def initialize(operation, options = {})
      self.operation = operation
      self.options = options
    end

    def after_commit(record)
      with_open_channel do |channel|
        channel.topic(topic_name).publish(record_data(record), routing_key: routing_key(record))
      end
    end

    def topic_name
      MultipleMan.configuration.topic_name
    end

    def routing_key(record)
      "#{record.model_name.singular}.#{operation}"
    end

  private

    attr_accessor :operation, :options

    def record_data(record)
      AttributeExtractor.new(record, fields).to_json
    end

    def fields
      options[:fields]
    end

    def with_open_channel
      connection = Bunny.new
      connection.start
      yield connection.create_channel
      connection.close
    end 
  end
end