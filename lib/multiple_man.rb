require "multiple_man/version"

module MultipleMan
  require 'multiple_man/railtie' if defined?(Rake)

  require 'multiple_man/mixins/publisher'
  require 'multiple_man/mixins/subscriber'
  require 'multiple_man/configuration'
  require 'multiple_man/model_subscriber'
  require 'multiple_man/model_publisher'
  require 'multiple_man/attribute_extractor'
  require 'multiple_man/connection'
  require 'multiple_man/routing_key'
  require 'multiple_man/listener'

  def self.logger
    MultipleMan.configuration.logger
  end
end
