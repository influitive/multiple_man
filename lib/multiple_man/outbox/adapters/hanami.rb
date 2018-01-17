module MultipleMan
  module Outbox
    module Adapter
      class MultipleManMessageRepository < Hanami::Repository
        self.relation = 'multiple_man_messages'

        def self.push_record(record, operation, options)
          data = PayloadGenerator.new(record, operation, options)

          new.create(
            payload:     data.payload,
            routing_key: routing_key(data.type, operation)
          )
        end

        def self.routing_key(type, operation)
          config      = MultipleMan.configuration
          alpha_topic = config.outbox_alpha? && config.alpha_topic_name

          options = {}
          options.merge!({ topic_name: alpha_topic }) if alpha_topic

          RoutingKey.new(type, operation, options).to_s
        end
      end

      class MultipleManMessage < Hanami::Entity; end
    end
  end
end
