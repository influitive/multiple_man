require 'bunny'

module MultipleMan
  class Connection
    def self.connection
      @connection ||= begin
        connection = Bunny.new(MultipleMan.configuration.connection)
        MultipleMan.logger.info "Connecting to #{MultipleMan.configuration.connection}"
        connection.start
        connection
      end
    end

    def self.open_channel
      Thread.current[:multiple_man_channel] ||= connection.create_channel
    end

    def self.connect
      channel = open_channel
      yield new(channel) if block_given?
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

  private

    attr_accessor :channel

  end
end