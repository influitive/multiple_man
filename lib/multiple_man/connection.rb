require 'bunny'
require 'connection_pool'
require 'active_support/core_ext/module'

module MultipleMan
  class Connection
    def self.connect
      connection = new
      yield connection if block_given?
    ensure
      connection.close! if connection
    end

    attr_reader :topic

    def initialize
      init_connection!
      init_channel!
      self.topic = channel.topic(topic_name)
    end

    def topic_name
      MultipleMan.configuration.topic_name
    end

    def close!
      channel.close if channel
      connection.close if connection
    end

    delegate :queue, to: :channel
    
  private

    def init_connection!
      self.connection = Bunny.new(MultipleMan.configuration.connection)
      connection.start
    end

    def init_channel!
      self.channel = connection.create_channel
    end

    attr_accessor :channel, :connection
    attr_writer :topic

  end
end