require 'active_support/core_ext'

module MultipleMan
  class ModelPublisher
    DEFAULT_OPTIONS = {
      update_unless: ->(r) {
        r.respond_to?(:previous_changes) && r.previous_changes.blank?
      }
    }.freeze

    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options).with_indifferent_access
      @update_unless = @options[:update_unless]
    end

    def publish(records, operation = :create)
      return unless MultipleMan.configuration.enabled

      Connection.connect do |connection|
        ActiveSupport::Notifications.instrument('multiple_man.publish_messages') do
          all_records(records) do |record|
            next if :update == operation && update_unless.call(record)

            ActiveSupport::Notifications.instrument('multiple_man.publish_message') do
              push_record(connection, record, operation)
            end
          end
        end
      end
    rescue Exception => ex
      MultipleMan.error(ex)
    end

  private

    attr_reader :options, :update_unless

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
