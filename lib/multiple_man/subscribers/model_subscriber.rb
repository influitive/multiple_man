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
      ModelFinder.new(payload, options, model_class).model
    end
   
    attr_writer :klass
    attr_accessor :model_class

    class ModelFinder
      def initialize(payload, options, model_class)
        self.payload = payload
        self.options = options
        self.model_class = model_class
      end
        
      def model
        model_class.where(conditions).first || model_class.new
      end

      def conditions
        hash = find_conditions
        if hash.keys.length > 1 && hash.keys.include?("id")
          id = hash.delete("id")
          hash.merge("source_id" => id)
        else
          hash
        end   
      end
        
      def find_conditions
        if options[:identify_by]
          Hash[[*options[:identify_by]].map{|k| [k, payload[k]]}]
        else
          payload.identify_by
        end
      end
        
    private  
        attr_accessor :payload, :options, :model_class
    end

  end
end
