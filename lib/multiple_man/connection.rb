require 'bunny'
require 'connection_pool'
require 'active_support/core_ext/module'

module MultipleMan
  class Connection
    @mutex = Mutex.new

    def self.connection
      @mutex.synchronize do 
        @connection ||= begin
          connection = Bunny.new(MultipleMan.configuration.connection)
          MultipleMan.logger.debug "Connecting to #{MultipleMan.configuration.connection}"
          connection.start
          connection
        end
      end
    end

    def self.connect
      channel = connection.create_channel
      yield new(channel) if block_given?
    ensure
      channel.close if channel
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