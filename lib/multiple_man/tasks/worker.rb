namespace :multiple_man do
  desc "Run multiple man listeners"
  task :worker => :environment do
    MultipleMan::Connection.connect do |connection|
      MultipleMan::Listener.start(connection)

      while(true)
        sleep 10
      end
    end
  end
end