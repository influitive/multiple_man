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
  db.connection.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";')
  db.connection.execute <<~SQL
    CREATE TABLE mm_test_users (
      id         BIGSERIAL PRIMARY KEY,
      name       varchar(255),
      uuid       uuid      default uuid_generate_v1(),
      created_at TIMESTAMP default NOW(),
      updated_at TIMESTAMP default NOW()
    )
  SQL

  db.connection.execute <<~SQL
    CREATE TABLE mm_test_profiles (
      id              BIGSERIAL PRIMARY KEY,
      mm_test_user_id BIGSERIAL,
      name            varchar(255),
      uuid            uuid      default uuid_generate_v1(),
      created_at      TIMESTAMP default NOW(),
      updated_at      TIMESTAMP default NOW()
    )
  SQL
end

def setup_rails
  require 'rails'
  require 'active_record'

  conn = { adapter: "postgresql", database: "postgres" }
  ActiveRecord::Base.establish_connection(conn)
end

def create_messages(count)
  require_relative '../lib/multiple_man/outbox/message/sequel'

  count.times do |i|
    message = sample_message(i)
    MultipleMan::Outbox::Message::Sequel.insert(message)
  end
end

def listener_klasses
  @routing_key ||= 3.times.map { |i| "User#{i}" }
end

def routing_keys
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
  db.connection.drop_table :mm_test_users
  db.connection.drop_table :mm_test_profiles
end

def wait_for(&block)
  max_wait      = 5
  total_wait    = 0
  wait_interval = 0.2
  while !yield && total_wait < max_wait
    total_wait += wait_interval
    sleep wait_interval
  end

  raise if total_wait > max_wait
end
