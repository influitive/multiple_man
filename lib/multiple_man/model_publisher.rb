module MultipleMan
  class ModelPublisher
    def after_commit(record)
      with_open_channel do |channel|
        channel.topic(topic_name).publish(record.to_json, routing_key: routing_key(record))
      end
    end

    # TODO - proper topic names and routing keys.
    def topic_name
      MultipleMan.configuration.topic_name
    end

    def routing_key(record)
      "#{record.model_name.singular}.create"
    end

  private

    def with_open_channel
      connection = Bunny.new
      connection.start
      yield connection.create_channel
      connection.close
    end 
  end
end