require "multiple_man/version"
require 'active_support'

module MultipleMan
  require 'multiple_man/railtie' if defined?(Rails)

  require 'multiple_man/mixins/publisher'
  require 'multiple_man/mixins/subscriber'
  require 'multiple_man/mixins/listener'
  require 'multiple_man/subscribers/base'
  require 'multiple_man/subscribers/model_subscriber'
  require 'multiple_man/subscribers/registry'
  require 'multiple_man/configuration'
  require 'multiple_man/model_publisher'
  require 'multiple_man/attribute_extractor'
  require 'multiple_man/payload_generator'
  require 'multiple_man/connection'
  require 'multiple_man/routing_key'
  require 'multiple_man/listeners/listener'
  require 'multiple_man/listeners/seeder_listener'
  require 'multiple_man/model_populator'
  require 'multiple_man/identity'
  require 'multiple_man/publish'

  require 'multiple_man/channel_maintenance/gc'
  require 'multiple_man/channel_maintenance/reaper'

  require 'multiple_man/payload/payload'
  require 'multiple_man/payload/v1'

  def self.logger
    configuration.logger
  end

  def self.disable!
    configuration.enabled = false
  end

  def self.enable!
    configuration.enabled = true
  end

  def self.error(ex, options = {})
    if configuration.error_handler
      configuration.error_handler.call(ex)
      raise ex if configuration.reraise_errors && options[:reraise] != false
    else
      raise ex
    end
  end
end
