require 'sequel'

extensions = %i[
  migration
]

extensions.each { |ext| Sequel.extension(ext) }

module MultipleMan
  module Outbox
    module DB
      module_function

      def connection
        @connection ||= begin
          Sequel.connect(MultipleMan.configuration.db_url)
        end
      end

      def run_migrations(db_url: MultipleMan.configuration.db_url)
        Sequel.connect(db_url) do |db|
          db.logger = MultipleMan.configuration.logger
          dir = File.join(__dir__, 'migrations')
          Sequel::TimestampMigrator.run(db, dir, table: :multiple_man_schema_info)
        end
      end
    end
  end
end
