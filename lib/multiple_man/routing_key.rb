module MultipleMan
  class RoutingKey
    ALLOWED_OPERATIONS = [:create, :update, :destroy, :seed, :"#"]

    def initialize(klass, operation = :"#", topic_name: default_topic_name)
      self.klass = klass
      self.operation = operation
      @topic_name = topic_name
    end

    def to_s
      if operation.to_sym == :seed
        "#{@topic_name}.#{operation}.#{klass}"
      else
        "#{@topic_name}.#{klass}.#{operation}"
      end
    end

    attr_reader :operation
    attr_accessor :klass

    def operation=(value)
      raise "Operation #{value} is not recognized" unless ALLOWED_OPERATIONS.include?(value.to_sym)
      @operation = value
    end

    def self.model_name(routing_key)
      routing_key.split('.')[1]
    end

    private

    def default_topic_name
      MultipleMan.configuration.topic_name
    end
  end
end
