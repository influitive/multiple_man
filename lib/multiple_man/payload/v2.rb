
class MultipleMan::Payload::V2
  def initialize(delivery_info, properties, payload)
    self.payload = payload
    self.delivery_info = delivery_info
    self.properties = properties
  end

  def keys
    payload.keys
  end

  def [](value)
    payload[value.to_s]
  end

  def identify_by
    Hash[identify_by_header.map do |key|
      [key, payload[key]]
    end]
  end

  def operation
    delivery_info.routing_key.split('.').last
  end

  def to_s
    delivery_info.routing_key
  end

private
  attr_accessor :payload, :delivery_info, :properties
  
  def identify_by_header
    JSON.parse(properties.headers['identify_by'])  
  end
end
