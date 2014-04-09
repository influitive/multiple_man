module MultipleMan::Subscribers
  class ModelSubscriber < Base

    def initialize(klass, options)
      super(klass)
      self.options = options
    end

    attr_accessor :options

    def create(payload)
      id = payload[:id]
      model = find_model(id)
      MultipleMan::ModelPopulator.new(model, options[:fields]).populate(id: find_conditions(id), data: payload[:data])
      model.save!
    end

    alias_method :update, :create
    alias_method :seed, :create

    def destroy(payload)
      model = find_model(payload[:id])
      model.destroy!
    end

  private

    def find_model(id)
      klass.where(find_conditions(id)).first || klass.new
    end

    def find_conditions(id)
      id.kind_of?(Hash) ? id : {multiple_man_identifier: id}
    end

    attr_writer :klass

  end
end
