require 'json'

module MultipleMan
  class AttributeExtractor

    def initialize(record, fields, include_previous = false)
      raise "Fields must be specified" unless fields
      
      self.include_previous = include_previous
      self.record = record
      self.fields = fields
    end

    def as_json
      if include_previous
        data.merge(previous_data)
      else
        data
      end
    end

  private

    def data
      Hash[fields.map do |field|
        [field, record.send(field)] 
      end]
    end

    def previous_data
      { previous: Hash[fields.map do |field|
          previous_data_method = "#{field}_was"
          [field, record.send(previous_data_method)] if record.respond_to? previous_data_method
        end.reject(&:nil?)]
      }
    end


    attr_accessor :record, :fields, :identifier, :include_previous

  end
end