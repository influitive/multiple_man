require "multiple_man/version"
require 'active_support'

module MultipleMan
  Error = Class.new(StandardError)
  ConsumerError = Class.new(Error)
  ProducerError = Class.new(Error)
  ConnectionError = Class.new(Error)

  require 'multiple_man/railtie' if defined?(Rails)

  require 'multiple_man/mixins/publisher'
  require 'multiple_man/mixins/subscriber'
  require 'multiple_man/mixins/listener'
  require 'multiple_man/subscribers/base'
  require 'multiple_man/subscribers/model_subscriber'
  require 'multiple_man/subscribers/registry'
  require 'multiple_man/tracers/null_tracer'
  require 'multiple_man/configuration'
  require 'multiple_man/model_publisher'
  require 'multiple_man/attribute_extractor'
  require 'multiple_man/payload_generator'
  require 'multiple_man/connection'
  require 'multiple_man/routing_key'
  require 'multiple_man/consumers/general'
  require 'multiple_man/consumers/seed'
  require 'multiple_man/model_populator'
  require 'multiple_man/identity'
  require 'multiple_man/publish'
  require 'multiple_man/runner'
  require 'multiple_man/cli'

  require 'multiple_man/channel_maintenance/gc'
  require 'multiple_man/channel_maintenance/reaper'

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
    raise ex unless configuration.error_handler

    if configuration.error_handler.arity == 3
      configuration.error_handler.call(ex, options[:payload], options[:delivery_info])
    else
      configuration.error_handler.call(ex)
    end

    raise ex if configuration.reraise_errors && options[:reraise] != false
  end
end
