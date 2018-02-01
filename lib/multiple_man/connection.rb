require 'bunny'
require 'active_support/core_ext/module'

module MultipleMan
  class Connection
    @mutex = Mutex.new

    def self.connect
      yield new(channel)
      Thread.current[:multiple_man_exception_retry_count] = 0
    rescue Bunny::Exception, Timeout::Error => e
      recovery_options = MultipleMan.configuration.connection_recovery
      MultipleMan.logger.debug "Bunny Error: #{e.inspect}"

      retry_count = Thread.current[:multiple_man_exception_retry_count] || 0
      retry_count += 1

      if retry_count < recovery_options[:max_retries]
        Thread.current[:multiple_man_exception_retry_count] = retry_count
        sleep recovery_options[:time_between_retries]
        retry
      else
        Thread.current[:multiple_man_exception_retry_count] = 0
        raise ConnectionError, e
      end
    end

    def self.channel
      Thread.current.thread_variable_get(:multiple_man_current_channel) || begin
        channel = connection.create_channel
        channel.confirm_select if MultipleMan.configuration.publisher_confirms
        Thread.current.thread_variable_set(:multiple_man_current_channel, channel)

        channel
      end
    end

    def self.connection
      @mutex.synchronize do
        @connection ||= begin
          connection = Bunny.new(
            MultipleMan.configuration.connection,
            {
              heartbeat_interval: 5,
              automatically_recover: true,
              recover_from_connection_close: true,
              network_recovery_interval: MultipleMan.configuration.connection_recovery[:time_before_reconnect]
            }.merge(MultipleMan.configuration.bunny_opts)
          )
          MultipleMan.logger.debug "Connecting to #{MultipleMan.configuration.connection}"
          connection.start

          connection
        end
      end
    end

    def self.reset!
      @mutex.synchronize do
        @connection.close if @connection
        @connection = nil
      end
    end

    attr_reader :topic
    delegate :queue, to: :channel

    def initialize(channel)
      self.channel = channel
      self.topic = channel.topic(topic_name, MultipleMan.configuration.exchange_opts)
    end

    def topic_name
      MultipleMan.configuration.topic_name
    end

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
