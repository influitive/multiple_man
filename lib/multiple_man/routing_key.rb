module MultipleMan
  class RoutingKey
    ALLOWED_OPERATIONS = [:create, :update, :destroy, :seed, :"#"]

    def initialize(klass, operation = :"#")
      self.klass = klass
      self.operation = operation
    end

    def to_s
      if operation == :seed
        "#{topic_name}.#{operation}.#{klass}"
      else
        "#{topic_name}.#{klass}.#{operation}"
      end
    end

    attr_reader :operation
    attr_accessor :klass

    def operation=(value)
      raise "Operation #{value} is not recognized" unless ALLOWED_OPERATIONS.include?(value)
      @operation = value
    end

  private
    def topic_name
      MultipleMan.configuration.topic_name
    end

  end
end
