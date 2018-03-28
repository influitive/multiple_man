module MultipleMan
  module Outbox
    module Message
      class Sequel < ::Sequel::Model(Outbox::DB.connection[:multiple_man_messages])
        def self.in_groups_and_delete(size = 100, &block)
          messages = Outbox::DB.connection.fetch(grouped_by_limit_sql(size)).all
          until messages.empty?
            yield(messages)
            where(id:
              messages.map { |h| h[:id] }
            ).delete
            messages = Outbox::DB.connection.fetch(grouped_by_limit_sql(size)).all
          end
        end

        private

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
