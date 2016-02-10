module MultipleMan::Subscribers
  class ModelSubscriber < Base

    def initialize(klass, options)
      self.model_class = klass
      super(options[:to] || klass.name)
      self.options = options
    end

    attr_accessor :options

    def create(payload)
      model = find_model(payload)
      MultipleMan::ModelPopulator.new(model, options[:fields]).populate(payload)
      model.save!
    end

    alias_method :update, :create
    alias_method :seed, :create

    def destroy(payload)
      model = find_model(payload)
      model.destroy!
    end

  private

    def find_model(payload)
      model_class.where(cleanse_id(payload.identify_by)).first || model_class.new
    end

    def cleanse_id(hash)
      if hash.keys.length > 1 && hash.keys.include?("id")
        id = hash.delete("id")
        hash.merge("source_id" => id)
      else
        hash
      end
    end

    attr_writer :klass
    attr_accessor :model_class

  end
end
