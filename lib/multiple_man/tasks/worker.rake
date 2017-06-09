namespace :multiple_man do
  desc 'Run multiple man listeners'
  task worker: :environment do
    MultipleMan::Runner.new(mode: :general).run
  end

  desc 'Run a seeding listener'
  task seed: :environment do
    MultipleMan::Runner.new(mode: :seed).run
  end
end
