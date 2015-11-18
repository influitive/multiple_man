module MultipleMan
  module ChannelMaintenance
    class GC
      def self.finalizer(thread_id, channel, queue, reaper)
        proc { queue << RemoveCommand.new(thread_id); reaper.push(channel) }
      end

      def initialize(_, reaper)
        @reaper = reaper
        @queue = Queue.new

        @executor = Thread.new do
          channels_by_thread = Hash.new {|h, k| h[k] = [] }
          loop do
            begin
              command = queue.pop
              command.execute(channels_by_thread)
            rescue
              puts "Sweeper died", $!
            end
          end
        end

        @sweeper_thread = Thread.new do
          loop do
            sleep 15
            queue << SweepCommand.new(queue, reaper)
          end
        end
      end

      def push(channel)
        thread_id = Thread.current.object_id

        finalizer = self.class.finalizer(thread_id, channel, queue, reaper)
        ObjectSpace.define_finalizer(Thread.current, finalizer)

        queue << AddCommand.new(thread_id, channel)

        puts "Opened channel #{channel.number}"
        self
      end

      def stop
        executor.kill
        executor.join

        sweeper_thread.kill
        sweeper_thread.join

        reaper.stop
      end

      private
      attr_reader :queue, :reaper, :executor, :sweeper_thread

      class AddCommand
        attr_reader :thread_id, :channel

        def initialize(thread_id, channel)
          @thread_id = thread_id
          @channel = channel
        end

        def execute(channels_by_thread)
          channels_by_thread[thread_id] << channel
        end
      end

      class RemoveCommand
        attr_reader :thread_id

        def initialize(thread_id)
          @thread_id = thread_id
        end

        def execute(channels_by_thread)
          channels_by_thread.delete(thread_id)
        end
      end

      class SweepCommand
        attr_reader :queue, :reaper
        def initialize(queue, reaper)
          @queue = queue
          @reaper = reaper
        end

        def execute(channels_by_thread)
          channels_by_thread.each do |thread_id, channels|
            thing = ObjectSpace._id2ref(thread_id) rescue nil
            next if thing.kind_of?(Thread) && thing.alive?

            channels.each {|c| reaper.push(c)}
            queue << RemoveCommand.new(thread_id)
          end
        end
      end
    end
  end
end
