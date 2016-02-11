module MultipleMan
  class PayloadGenerator
    def initialize(record, operation = :create, options = {})
      self.record = record
      self.operation = operation.to_s
      self.options = options
    end

    def payload
      data.to_json
    end
    
    def headers
      { 
        'version' => '2',
        'identify_by' => identify_by.to_json 
      }
    end

    def type
      options[:as] || record.class.name
    end

    def identify_by
      [* (options[:identify_by] || :id) ]       
    end

    def data
      if options[:with]
        options[:with].new(record).as_json
      else
        AttributeExtractor.new(record, options[:fields]).as_json
      end
    end

    attr_reader :operation

  private

    attr_accessor :record, :options
    attr_writer :operation

  end
end