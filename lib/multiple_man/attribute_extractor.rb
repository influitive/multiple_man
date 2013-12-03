require 'json'

module MultipleMan
  class AttributeExtractor

    def initialize(record, fields)
      raise "Fields must be specified" unless fields
      
      self.record = record
      self.fields = fields 
    end

    def data
      Hash[fields.map do |field|
        [field, record.send(field)]
      end]
    end

    def to_json
      data.to_json
    end

  private

    attr_accessor :record, :fields

  end
end