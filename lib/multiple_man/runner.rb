require 'forwardable'

module MultipleMan
  def self.trap_signals!
    return if @signals_trapped

    @signals_trapped = true

    handler = proc do |signal|
      puts "received #{Signal.signame(signal)}"
      exit
    end

    %w(INT QUIT TERM).each { |signal| Signal.trap(signal, handler) }
  end

  class Runner
    extend Forwardable

    MODES = [:general, :seed].freeze

    def initialize(options = {})
      @mode = options.fetch(:mode, :general)

      raise ArgumentError, "undefined mode: #{mode}" unless MODES.include?(mode)
    end

    def run
      MultipleMan.trap_signals!
      preload_framework!
      channel.prefetch(prefetch_size)
      build_listener.listen
      sleep
    end

    private

    attr_reader :mode

    def_delegators :config, :prefetch_size, :queue_name, :listeners, :topic_name

    def preload_framework!
      Rails.application.eager_load! if defined?(Rails)
      Hanami::Application.preload_applications! if defined?(Hanami)
    end

    def build_listener
      listener_class.new(
        queue: channel.queue(*queue_params),
        subscribers: listeners,
        topic: topic
      )
    end

    def listener_class
      if seeding?
        Consumers::Seed
      else
        Consumers::General
      end
    end

    def queue_params
      if seeding?
        ["#{queue_name}.seed", durable: false, auto_delete: true]
      else
        [queue_name, durable: true, auto_delete: false]
      end
    end

    def channel
      @channel ||= Connection.connection.create_channel
    end

    def topic
      @topic ||= channel.topic(topic_name)
    end

    def config
      MultipleMan.configuration
    end

    def seeding?
      mode == :seed
    end
  end
end
