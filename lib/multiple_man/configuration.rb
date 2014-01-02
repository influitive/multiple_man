module MultipleMan
  class Configuration

    def initialize
      self.topic_name = "multiple_man"
      self.app_name = Rails.application.class.parent.to_s if defined?(Rails)
      self.logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      self.enabled = true
    end

    attr_accessor :topic_name, :app_name, :connection, :logger, :enabled
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end
end