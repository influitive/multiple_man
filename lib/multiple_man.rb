require "multiple_man/version"

module MultipleMan
  require 'multiple_man/railtie' if defined?(Rake)

  require 'multiple_man/mixins/publisher'
  require 'multiple_man/mixins/subscriber'
  require 'multiple_man/subscribers/base'
  require 'multiple_man/subscribers/model_subscriber'
  require 'multiple_man/subscribers/registry'
  require 'multiple_man/configuration'
  require 'multiple_man/model_publisher'
  require 'multiple_man/attribute_extractor'
  require 'multiple_man/connection'
  require 'multiple_man/routing_key'
  require 'multiple_man/listener'
  require 'multiple_man/seeder_listener'
  require 'multiple_man/model_populator'
  require 'multiple_man/identity'
  require 'multiple_man/publish'

  def self.logger
    configuration.logger
  end

  def self.disable!
    configuration.enabled = false
  end

  def self.enable!
    configuration.enabled = true
  end

  def self.error(ex)
    if configuration.error_handler
      configuration.error_handler.call(ex)
    else
      raise ex
    end
  end
end
