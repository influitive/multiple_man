namespace :multiple_man do
  desc "Run multiple man listeners"
  task worker: :environment do
    channel = MultipleMan::Connection.connection.create_channel
    channel.prefetch(100)
    queue_name = MultipleMan.configuration.queue_name
    queue = channel.queue(queue_name, durable: true, auto_delete: false)

    run_listener(MultipleMan::Consumers::General, queue)
  end

  desc 'Run a seeding listener'
  task seed: :environment do
    channel = MultipleMan::Connection.connection.create_channel
    channel.prefetch(100)
    queue_name = MultipleMan.configuration.queue_name + '.seed'
    queue = channel.queue(queue_name, durable: false, auto_delete: true)

    run_listener(MultipleMan::Consumers::Seed, queue)
  end

  def run_listener(listener, queue)
    Rails.application.eager_load! if defined?(Rails)

    subscribers = MultipleMan.configuration.listeners
    topic = MultipleMan.configuration.topic_name

    listener.new(subscribers: subscribers, queue: queue, topic: topic).listen

    Signal.trap("INT") { puts "received INT"; exit }
    Signal.trap("QUIT") { puts "received QUIT"; exit }
    Signal.trap("TERM") { puts "received TERM"; exit }

    sleep
  end

  desc 'Run transitional worker'
  task transition_worker: :environment do
    Rails.application.eager_load! if defined?(Rails)

    topic = MultipleMan.configuration.topic_name
    app_name = MultipleMan.configuration.app_name
    channel = MultipleMan::Connection.connection.create_channel
    channel.prefetch(100)

    MultipleMan.configuration.listeners.each do |listener|
      queue_name = listener.respond_to?(:queue_name) ?
                     listener.queue_name :
                     "#{topic}.#{app_name}.#{listener.listen_to}"

      next unless MultipleMan::Connection.connection.queue_exists?(queue_name)
      queue = channel.queue(queue_name, durable: true, auto_delete: false)

      MultipleMan::Consumers::Transitional.new(subscription: listener, queue: queue, topic: topic).listen
    end

    Signal.trap("INT") { puts "received INT"; exit }
    Signal.trap("QUIT") { puts "received QUIT"; exit }
    Signal.trap("TERM") { puts "received TERM"; exit }

    sleep
  end

end
