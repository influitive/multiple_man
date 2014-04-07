module MultipleMan
  class Configuration

    def initialize
      self.topic_name = "multiple_man"
      self.app_name = Rails.application.class.parent.to_s if defined?(Rails)
      self.enabled = true
      self.channel_pool_size = 5
      self.worker_concurrency = 1
    end

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end

    def on_error(&block)
      @error_handler = block
    end

    attr_accessor :topic_name, :app_name, :connection, :enabled, :channel_pool_size, :error_handler, 
                  :worker_concurrency
    attr_writer :logger
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end
end