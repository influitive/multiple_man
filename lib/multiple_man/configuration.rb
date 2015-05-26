module MultipleMan
  class Configuration

    def initialize
      self.topic_name = "multiple_man"
      self.app_name = Rails.application.class.parent.to_s if defined?(Rails)
      self.enabled = true
      self.worker_concurrency = 1
      self.reraise_errors = true
      self.connection_recovery = {
        time_before_reconnect: 0.2,
        time_between_retries: 0.8,
        max_retries: 5
      }
    end

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end

    def on_error(&block)
      @error_handler = block
    end

    attr_accessor :topic_name, :app_name, :connection, :enabled, :error_handler,
                  :worker_concurrency, :reraise_errors, :connection_recovery
    attr_writer :logger
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end
end
