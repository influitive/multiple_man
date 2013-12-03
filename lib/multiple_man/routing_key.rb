module MultipleMan
  class RoutingKey
    ALLOWED_OPERATIONS = [:create, :update, :destroy, :"#"]

    def initialize(klass, operation = :"#")
      self.klass = klass
      self.operation = operation
    end

    def to_s
      "#{klass.name}.#{operation}"
    end

    attr_reader :operation
    attr_reader :klass

    def operation=(value)
      raise "Operation #{value} is not recognized" unless ALLOWED_OPERATIONS.include?(value)
      @operation = value
    end

    def klass=(value)
      @klass = (value.is_a?(Class) ? value : value.class)
    end

  end
end