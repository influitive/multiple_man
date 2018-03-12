require 'active_support/core_ext'

module MultipleMan
  module Publisher
    def Publisher.included(base)
      base.extend(ClassMethods)

      if MultipleMan.configuration.outbox_alpha?
        add_in_commit_hooks(base)
        add_post_commit_hooks(base)
      elsif MultipleMan.configuration.at_least_once?
        add_in_commit_hooks(base)
      else
        add_post_commit_hooks(base)
      end

      base.class_attribute :multiple_man_publisher
    end

    def multiple_man_publish(operation=:create)
      if MultipleMan.configuration.outbox_alpha?
        multiple_man_publish_outbox_false(operation)
        multiple_man_publish_outbox_true(operation)
      elsif MultipleMan.configuration.at_least_once?
        multiple_man_publish_outbox_true(operation)
      else
        multiple_man_publish_outbox_false(operation)
      end
    end

    def multiple_man_publish_outbox_false(operation)
      self.class.multiple_man_publisher.publish(self, operation, outbox: false)
    end

    def multiple_man_publish_outbox_true(operation)
      self.class.multiple_man_publisher.publish(self, operation, outbox: true)
    end

    private

    def self.add_in_commit_hooks(base)
      if base.respond_to?(:after_save)
        base.after_save { |r|
          return true unless r.respond_to?(:created_at) && r.respond_to?(:updated_at)

          if r.created_at == r.updated_at
            r.multiple_man_publish_outbox_true(:create)
          else
            r.multiple_man_publish_outbox_true(:update)
          end
        }
      end

      if base.respond_to?(:before_destroy)
        base.before_destroy { |r| r.multiple_man_publish_outbox_true(:destroy) }
      end

      if base.respond_to?(:after_touch)
        base.after_touch { |r| r.multiple_man_publish_outbox_true(:update) }
      end
    end

    def self.add_post_commit_hooks(base)
      if base.respond_to?(:after_commit)
        base.after_commit(on: :create) { |r| r.multiple_man_publish_outbox_false(:create) }
        base.after_commit(on: :update) do |r|
          if !r.respond_to?(:previous_changes) || r.previous_changes.any?
            r.multiple_man_publish_outbox_false(:update)
          end
        end
        base.after_commit(on: :destroy) { |r| r.multiple_man_publish_outbox_false(:destroy) }
      end
    end

    module ClassMethods

      def multiple_man_publish(operation=:create)
        multiple_man_publisher.publish(self, operation)
      end

      def publish(options = {})
        self.multiple_man_publisher = ModelPublisher.new(options)
      end
    end
  end
end
