module MultipleMan
  module Publisher
    def Publisher.included(base)
      base.class_eval do
        after_commit ModelPublisher.new(:create), on: :create
        after_commit ModelPublisher.new(:update), on: :update
        after_commit ModelPublisher.new(:destroy), on: :destroy
      end
    end
  end
end