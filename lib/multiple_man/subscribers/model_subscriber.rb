module MultipleMan::Subscribers
  class ModelSubscriber < Base

    def initialize(klass, options)
      self.model_class = klass
      super(options[:to] || klass.name)
      self.options = options
    end

    attr_accessor :options

    def create(payload)
      id = payload[:id]
      model = find_model(id)
      MultipleMan::ModelPopulator.new(model, options[:fields]).populate(id: find_conditions(id), data: payload[:data])
      model.save!
    rescue
      MultipleMan.logger.info "FIND: #{find_conditions(id)}"
      MultipleMan.logger.info "SUBSCRIBER MODEL CHANGES: #{model.changed_attributes.inspect}"

      raise
    end

    alias_method :update, :create
    alias_method :seed, :create

    def destroy(payload)
      model = find_model(payload[:id])
      model.destroy!
    end

  private

    def find_model(id)

      model_class.where(find_conditions(id)).first || model_class.new
    end

    def find_conditions(id)
      id.kind_of?(Hash) ? cleanse_id(id) : {multiple_man_identifier: id}
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
