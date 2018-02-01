require 'bunny'
require 'active_support/core_ext/module'
require 'connection_pool'

module MultipleMan
  module Connection
    module_function

    @mutex = Mutex.new

    def channel_pool
      @channel_pool ||= ConnectionPool.new(size: MultipleMan.configuration.channel_pool_size) do
        channel = bunny_connection.create_channel
        channel.confirm_select if MultipleMan.configuration.publisher_confirms
        channel.topic(topic_name, MultipleMan.configuration.exchange_opts)
        channel
      end
    end

    def close
      channel_pool.shutdown(&:close)
      bunny_connection.close
      @channel_pool = nil
      @connection   = nil
    end

    def topic_name
      MultipleMan.configuration.topic_name
    end

    def bunny_connection
      @mutex.synchronize do
        @connection ||= begin
          connection = Bunny.new(
            MultipleMan.configuration.connection,
            {
              heartbeat_interval:            5,
              automatically_recover:         true,
              recover_from_connection_close: true,
              network_recovery_interval:     MultipleMan.configuration.connection_recovery[:time_before_reconnect]
            }.merge(MultipleMan.configuration.bunny_opts)
          )
          MultipleMan.logger.debug "Connecting to #{MultipleMan.configuration.connection}"
          connection.start

          connection
        end
      end
    end
  end
end
