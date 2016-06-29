namespace :multiple_man do
  desc 'Run multiple man listeners'
  task worker: :environment do
    MultipleMan::Runner.new(mode: :general).run
  end

  desc 'Run a seeding listener'
  task seed: :environment do
    MultipleMan::Runner.new(mode: :seed).run
  end

  desc 'Run transitional worker'
  task transition_worker: :environment do
    Rails.application.eager_load! if defined?(Rails)

    topic = MultipleMan.configuration.topic_name
    app_name = MultipleMan.configuration.app_name
    channel = MultipleMan::Connection.connection.create_channel
    channel.prefetch(MultipleMan.configuration.prefetch_size)

    MultipleMan.configuration.listeners.each do |listener|
      queue_name = listener.respond_to?(:queue_name) ?
                     listener.queue_name :
                     "#{topic}.#{app_name}.#{listener.listen_to}"

      next unless MultipleMan::Connection.connection.queue_exists?(queue_name)
      queue = channel.queue(queue_name, durable: true, auto_delete: false)

      MultipleMan::Consumers::Transitional.new(subscription: listener, queue: queue, topic: topic).listen
    end

    MultipleMan.trap_signals!
    sleep
  end

end
