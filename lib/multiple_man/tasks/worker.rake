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

    listener.start

    while(true)
      sleep 10
    end
  end
end
