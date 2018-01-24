module MultipleMan
  module Outbox
    module Adapter
      class Rails < ::ActiveRecord::Base
        self.table_name = 'public.multiple_man_messages'

        def self.push_record(record, operation, options)
          data = PayloadGenerator.new(record, operation, options)

          new(
            payload:     data.payload,
            routing_key: routing_key(data.type, operation)
          ).save!
        end

        def self.routing_key(type, operation)
          config      = MultipleMan.configuration
          alpha_topic = config.outbox_alpha? && config.alpha_topic_name

          options = {}
          options.merge!({ topic_name: alpha_topic }) if alpha_topic

          RoutingKey.new(type, operation, options).to_s
        end
      end
    end
  end
end
