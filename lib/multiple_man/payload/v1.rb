
class MultipleMan::Payload::V1
  def initialize(delivery_info, properties, payload)
    self.payload = payload
    self.delivery_info = delivery_info
  end

  def keys
    (payload['data'].keys + payload['id'].keys).uniq
  end

  def [](value)
    payload['data'][value.to_s] || payload['id'][value.to_s]
  end

  def identify_by
    if payload['id'].is_a?(Hash)
      payload['id']
    else
      {'multiple_man_identifier' => payload['id']}
    end
  end

  def operation
    payload['operation'] || delivery_info.routing_key.split('.').last
  end

  def to_s
    delivery_info.routing_key
  end

private
  attr_accessor :payload, :delivery_info
end
