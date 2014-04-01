module MultipleMan
  class Identity
    def self.build(record, options)
      if options[:identifier].present?
        SingleField.new(record, options[:identifier])
      else
        MultipleField.new(record, options[:identify_by])
      end
    end

    def initialize(record)
      self.record = record
    end

    attr_accessor :record

    class MultipleField < Identity
      def initialize(record, identify_by)
        self.identify_by = identify_by ? [*identify_by] : [:id]
        super(record)
      end
      def value
        Hash[identify_by.map do |field|
          [field, record.send(field)]
        end]
      end

      attr_accessor :identify_by
    end

    class SingleField < Identity
      def initialize(record, identifier = :id)
        MultipleMan.logger.warn("Using :identifier in publish is deprecated, please switch to identify_by.")
        self.identifier = identifier || :id
        super(record)
      end

      def value
        if identifier.class == Proc
          identifier.call(record).to_s
        else
          record.send(identifier).to_s
        end
      end

      attr_accessor :identifier
    end
  end
end