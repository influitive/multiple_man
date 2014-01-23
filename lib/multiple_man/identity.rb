module MultipleMan
  class Identity
    def initialize(record, identifier = :id)
      self.record = record
      self.identifier = identifier || :id
    end

    def value
      if identifier.class == Proc
        identifier.call(record).to_s
      else
        record.send(identifier).to_s
      end
    end

    attr_accessor :record, :identifier
  end
end