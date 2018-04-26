module MultipleMan
  module Outbox
    module Message
      class Sequel < ::Sequel::Model(Outbox::DB.connection[:multiple_man_messages])
        def self.in_groups_and_delete(size = 100, &block)
          messages = fetch_messages_from_database(size)

          until messages.empty?
            yield(messages)
            where(id:
              messages.map { |h| h[:id] }
            ).delete
            messages = fetch_messages_from_database(size)
          end
        end

        private

        def self.fetch_messages_from_database(size)
          # This is just here for instrumentation, but hopefully the table stays small enough it will not impact performance much
          table_count = Outbox::DB.connection.execute("SELECT COUNT(*) FROM multiple_man_messages;")

          ActiveSupport::Notifications.instrument('multiple_man.producer.outbox_db_fetch', table_count: table_count) do |payload|
            messages = Outbox::DB.connection.fetch(grouped_by_limit_sql(size)).all
            payload[:message_count] = messages.size
            messages
          end
        end

        def self.grouped_by_limit_sql(size)
          <<~SQL
            select *
            from (
              select *, row_number() over (
                partition by set_name order by id
              ) as rownum from multiple_man_messages
            ) msgs
            where msgs.rownum <= #{size};
          SQL
        end
      end
    end
  end
end
