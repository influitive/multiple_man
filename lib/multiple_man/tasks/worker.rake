namespace :multiple_man do
  desc "Run multiple man listeners"
  task :worker => :environment do
    run_listener(MultipleMan::Listener)
  end

  desc 'Run a seeding listener'
  task seed: :environment do
    run_listener(MultipleMan::SeederListener)
  end

  def run_listener(listener)
    Rails.application.eager_load!

    if defined?(ActiveRecord::Base)
      config = ActiveRecord::Base.configurations[Rails.env] ||
                  Rails.application.config.database_configuration[Rails.env]
      config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
      config['pool']            =   ENV['DB_POOL'] || 20
      ActiveRecord::Base.establish_connection(config)
    end

    channel = MultipleMan::Connection.connection.create_channel(nil, MultipleMan.configuration.worker_concurrency)
    connection = MultipleMan::Connection.new(channel)

    listener.start(connection)

    while(true)
      sleep 10
    end
  end
end
