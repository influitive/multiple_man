namespace :multiple_man do
  desc "Run multiple man listeners"
  task worker: :environment do
    channel = MultipleMan::Connection.connection.create_channel
    queue_name = MultipleMan.configuration.queue_name
    queue = channel.queue(queue_name, durable: true, auto_delete: false)

    run_listener(MultipleMan::Listeners::Listener, queue)
  end

  desc 'Run a seeding listener'
  task seed: :environment do
    channel = MultipleMan::Connection.connection.create_channel
    queue_name = MultipleMan.configuration.queue_name + '.seed'
    queue = channel.queue(queue_name, durable: false, auto_delete: true)

    run_listener(MultipleMan::Listeners::SeederListener, queue)
  end

  def run_listener(listener, queue)
    Rails.application.eager_load!

    subscribers = MultipleMan.configuration.listeners
    topic = MultipleMan.configuration.topic_name

    listener.new(subscribers: subscribers, queue: queue, topic: topic).listen

    Signal.trap("INT") { puts "received INT"; exit }
    Signal.trap("QUIT") { puts "received QUIT"; exit }
    Signal.trap("TERM") { puts "received TERM"; exit }

    sleep
  end
end
