class MultipleMan::Payload
  def self.build(delivery_info, properties, data)
    case properties.headers["version"]
    when "1", nil
        V1.new(delivery_info, properties, data)
    when "2"
        V2.new(delivery_info, properties, data)
    else
        raise "This version of MultipleMan does not support the payload version supplied (#{properties.headers["version"]}). Please upgrade to the latest version."
    end    
  end
end
