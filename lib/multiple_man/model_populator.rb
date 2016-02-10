module MultipleMan
  class ModelPopulator

    def initialize(record, fields)
      self.record = record
      self.fields = fields
    end

    def populate(payload)
      fields_for(payload).each do |field|
        source, dest = field.is_a?(Array) ? field : [field, field]
        populate_field(dest, payload[source])
      end
      record
    end

  private
    attr_accessor :record, :fields

    # Raise an exception if explicit fields were provided.
    def should_raise?
      fields.present?
    end

    def populate_field(field, value)
      # Attempts to populate source id if id is specified
      if field.to_s == 'id' && record.respond_to?('source_id')
        field = 'source_id'
      end

      setter = "#{field}="
      if record.respond_to?(setter)
        record.send(setter, value)
      elsif should_raise?
        raise "Record #{record} does not respond to #{setter}"
      end
    end

    def fields_for(payload)
      fields || payload.keys
    end
  end
end
