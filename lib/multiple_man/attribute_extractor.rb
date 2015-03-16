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
        data.merge({previous: data("_was")})
      else
        data
      end
    end

  private

    def data(suffix = nil)
      Hash[fields.map do |field|
        get_field(field, suffix)
      end.reject(&:nil?)]
    end

    def get_field(field, suffix)
      method = "#{field}#{suffix}"
      [field, record.send(method)] if record.respond_to? method
    end

    attr_accessor :record, :fields, :identifier, :include_previous

  end
end
