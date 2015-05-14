require 'bunny'
require 'connection_pool'
require 'active_support/core_ext/module'

module MultipleMan
  class Connection

    def self.connect
      connection = Bunny.new(MultipleMan.configuration.connection)
      MultipleMan.logger.debug "Connecting to #{MultipleMan.configuration.connection}"
      connection.start
      channel = connection.create_channel
      yield new(channel) if block_given?
    ensure
      channel.close if channel && channel.open?
      connection.close if connection && connection.open?
    end

    attr_reader :topic

    def initialize(channel)
      self.channel = channel
      self.topic = channel.topic(topic_name)
    end

    def topic_name
      MultipleMan.configuration.topic_name
    end

    delegate :queue, to: :channel

  private

    attr_accessor :channel
    attr_writer :topic

  end
end
