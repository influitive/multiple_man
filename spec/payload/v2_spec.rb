require 'spec_helper'

describe MultipleMan::Payload::V2 do
  let(:delivery_info) {
    double(:delivery_info, routing_key: 'blah.blah.create')
  }
  
  let(:properties) {
    double(:properties, headers: {
      'version' => '2',
      'identify_by' => ['id', 'database'].to_json
    })
  }

  let(:payload) {
    described_class.new(delivery_info, properties, {
      'id' => 1,
      'database' => 'app',
      'foo' => 'bar'
    })
  }

  it "should return appropriate identify_by keys" do
    expect(payload.identify_by).to eq({'id' => 1, 'database' => 'app'})
  end

  it "should return appropriate keys" do
    expect(payload.keys).to eq(['id', 'database', 'foo'])
  end

  it 'should store data appropriately' do
    expect(payload['id']).to eq(1)
    expect(payload['database']).to eq('app')
    expect(payload['foo']).to eq('bar')
  end

  it "should have an operation" do
    expect(payload.operation).to eq('create')
  end
end