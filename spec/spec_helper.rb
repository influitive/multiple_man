require 'bundler/setup'
require 'bunny'
require 'ostruct'
require 'pry'

require_relative '../lib/multiple_man.rb'

def configure_multiple_man
  MultipleMan.configure do |config|
    config.exchange_opts             = { durable: true }
    config.logger.level              = 'FATAL' # null logger
    config.publisher_confirms        = true
    config.app_name                  = 'test_suite'
    MultipleMan.configuration.db_url = 'postgresql://0.0.0.0:5432/postgres'
  end
end
configure_multiple_man

def setup_db
  require 'multiple_man/outbox/db'

  db.run_migrations
end

def create_messages(count)
  require_relative '../lib/multiple_man/outbox/adapters/general'

  count.times do |i|
    message = sample_message(i)
    MultipleMan::Outbox::Adapters::General.insert(message)
  end
end

def routing_keys
  listener_klasses = 3.times.map { |i| "User#{i}" }

  @routing_key ||= listener_klasses.map do |klass|
    "multiple_man.#{klass}.create"
  end
end

def sample_message(i)
  message = {
    routing_key: routing_keys.sample,
    payload:     { counter: i }.to_json,
    created_at:  Time.now,
    updated_at:  Time.now
  }
end

def db
  require 'multiple_man/outbox/db'

  MultipleMan::Outbox::DB
end

def clear_db
  db.connection.drop_table :multiple_man_schema_info
  db.connection.drop_table :multiple_man_messages
end
