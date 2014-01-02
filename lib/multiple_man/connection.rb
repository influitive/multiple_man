module MultipleMan
  class Connection
    def self.connect
      MultipleMan.logger.info "Connecting to #{MultipleMan.configuration.connection}"
      connection = Bunny.new(MultipleMan.configuration.connection)
      MultipleMan.logger.info "Starting connection - block #{block_given?}"
      connection.start
      yield new(connection) if block_given?
    ensure
      MultipleMan.logger.info "Closing connection"
      connection.close
    end

    def initialize(connection)
      self.connection = connection
    end

    def channel
      @channel ||= connection.create_channel
    end

    def topic
      @topic ||= channel.topic(topic_name)
    end

    def topic_name
      MultipleMan.configuration.topic_name
    end

  private

    attr_accessor :connection

  end
end