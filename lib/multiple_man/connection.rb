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

    def self.connect
      channel = connection.create_channel
      begin
        yield new(channel) if block_given?
      ensure
        channel.close
      end
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