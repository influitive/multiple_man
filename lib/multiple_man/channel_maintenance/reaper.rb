module MultipleMan
  module ChannelMaintenance
    class Reaper
      def initialize(config)
        @config = config
        @queue = Queue.new

        @worker = Thread.new do
          loop do
            channel = queue.pop
            begin
              channel.close unless channel.closed?
              puts "Channel #{channel.number} closed!"
            rescue Bunny::Exception, Timeout::Error
              sleep config.connection_recovery[:time_between_retries]
              retry
            end
          end
        end
      end

      def push(channel)
        queue << channel
      end

      def stop
        worker.kill
        worker.join
      end

      private
      attr_reader :config, :queue, :worker
    end
  end
end
