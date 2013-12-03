module MultipleMan
  class Configuration
    attr_accessor :app_name
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end
end