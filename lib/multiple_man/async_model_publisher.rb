module MultipleMan
  class AsyncModelPublisher < ModelPublisher

    def publish(records, operation=:create)
      return unless MultipleMan.configuration.enabled

      if records.respond_to?(:pluck)
        return unless records.any?
        ids = records.pluck(:id)
        klass = records.first.class.name
      else
        return if records.nil?
        ids = [records.id]
        klass = records.class.name
      end

      ModelPublisherJob.perform_async(klass, ids, options, operation)
    end

  end

  class ModelPublisherJob
    include Sidekiq::Worker

    def perform(record_type, ids, options, operation)
      records = Kernel.const_get(record_type).where(id: ids)
      ModelPublisher.new(options).publish(records, operation)
    end
  end
end
