require 'bunny'
require 'active_support/core_ext/module'

module MultipleMan
  class Connection
    @mutex = Mutex.new

    def self.connect
      channel = connection.create_channel
      yield new(channel) if block_given?
    rescue Bunny::Exception
      reset!
      retry
    ensure
      channel.close if channel && channel.open?
    end

    attr_reader :topic

    def initialize(channel)
      self.channel = channel
      self.topic = channel.topic(topic_name)
    end

    def self.connection
      @mutex.synchronize do
        @connection ||= begin
          connection = Bunny.new(MultipleMan.configuration.connection, heartbeat: 5)
          MultipleMan.logger.debug "Connecting to #{MultipleMan.configuration.connection}"
          connection.start

          connection
        end
      end
    end

    def self.reset!
      @connection.close if @connection

      @connection = nil
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

__END__

# Possible usage

Unicorn.after_fork do
  MultipleMan::Connection.reset!
end

Sidekiq.configure_server do |config|
  MultipleMan::Connection.reset!
end

PhusionPassenger.on_event(:starting_worker_process) do |forked|
  MultipleMan::Connection.reset! if forked
end
