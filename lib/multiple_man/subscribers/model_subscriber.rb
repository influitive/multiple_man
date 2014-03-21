module MultipleMan::Subscribers
  class ModelSubscriber < Base

    def initialize(klass, options)
      super(klass)
      self.options = options
    end

    attr_accessor :options

    def create(payload)
      model = find_model(payload[:id])
      MultipleMan::ModelPopulator.new(model, options[:fields]).populate(payload[:data])
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
      klass.find_or_initialize_by(multiple_man_identifier: id)
    end

    attr_writer :klass

  end
end
