module MultipleMan
  module Publisher
    def Publisher.included(base)
      base.extend(ClassMethods)
      base.after_commit(on: :create) { |r| r.multiple_man_publish(:create) }
      base.after_commit(on: :update) { |r| r.multiple_man_publish(:update) }
      base.after_commit(on: :destroy) { |r| r.multiple_man_publish(:destroy) }
    end

    def multiple_man_publish(operation=:create)
      self.class.multiple_man_publisher.publish(self, operation) 
    end

    module ClassMethods
      
      def multiple_man_publish(operation=:create)
        multiple_man_publisher.publish(self, operation) 
      end

      attr_accessor :multiple_man_publisher

      def publish(options = {})
        self.multiple_man_publisher = ModelPublisher.new(options)
      end
    end
  end
end