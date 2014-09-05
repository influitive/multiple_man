require 'bunny'
require 'connection_pool'
require 'active_support/core_ext/module'

module MultipleMan
  class Connection
    def self.connection
      @connection ||= begin
        connection = Bunny.new(MultipleMan.configuration.connection)
        MultipleMan.logger.debug "Connecting to #{MultipleMan.configuration.connection}"
        connection.start
        connection
      end
    end

    def self.channel
      # TODO : What to do in case of closed channel
      Thread.current[:multiple_man_channel] ||= connection.create_channel
    end

    def self.connect
      yield new(self.channel) if block_given?
    end

    def initialize(channel)
      self.channel = channel
    end

    def topic
      @topic ||= channel.topic(topic_name)
    end

    def topic_name
      MultipleMan.configuration.topic_name
    end

    delegate :queue, to: :channel
    
  private

    attr_accessor :channel

  end
end