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

    def as_json
      data
    end

  private

    attr_accessor :record, :fields, :identifier

  end
end