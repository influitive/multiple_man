module MultipleMan
  module Publisher
    def Publisher.included(base)
      base.class_eval do
        after_commit ModelPublisher.new
      end
    end
  end
end