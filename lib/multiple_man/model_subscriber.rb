module MultipleMan
  class ModelSubscriber

    @subscriptions = []
    class << self
      attr_accessor :subscriptions

      def register(klass)
        self.subscriptions << new(klass)
      end
    end

    def initialize(klass)
      self.klass = klass
    end

    attr_reader :klass    

    def create(data)
      klass.new(data).save
    end

    def update(data)
      model = find_model(data)
      model.attributes = data
      model.save
    end

    def destroy(data)
      model = find_model(data)
      model.destroy
    end

  private

    def find_model(data)
      klass.find_by_remote_id(data[:id])
    end

    attr_writer :klass

  end
end