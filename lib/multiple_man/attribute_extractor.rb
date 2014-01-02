require 'json'

module MultipleMan
  class AttributeExtractor

    def initialize(record, fields, identifier)
      raise "Fields must be specified" unless fields
      
      self.record = record
      self.fields = fields 
      self.identifier = identifier
    end

    def data
      {
        id: identifier_for_record,
        data: Hash[fields.map do |field|
          [field, record.send(field)]
        end]
      }
    end

    def identifier_for_record
      puts identifier.class
      if identifier.class == Symbol
        record.send(identifier)
      elsif identifier.class == Proc
        identifier.call(record)
      else
        record.id
      end
    end

    def to_json
      data.to_json
    end

  private

    attr_accessor :record, :fields, :identifier

  end
end