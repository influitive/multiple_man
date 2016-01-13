require 'spec_helper'

describe MultipleMan::Payload::V1 do
  let(:delivery_info) {
    double(:delivery_info, routing_key: 'blah.blah.create')
  }

  let(:payload) {
    described_class.new(delivery_info, nil, {
      'id' => {
        'id' => 1,
        'database' => 'app'
      },
      'data' => {
        'id' => 1,
        'database' => 'app',
        'foo' => 'bar'
      }
    })
  }

  it "should return appropriate identify_by keys" do
    expect(payload.identify_by).to eq({'id' => 1, 'database' => 'app'})
  end

  it "should return appropriate keys" do
    expect(payload.keys).to eq(['id', 'database', 'foo'])
  end

  it "should include keys from the id even if they're not in the data" do
    payload = described_class.new(nil, nil, {'id' => {'id' => 1}, 'data' => { 'foo' => 'bar'}})
    expect(payload.keys).to include('id')
  end


  it "should construct a multiple man identifier id if none exists" do
    payload = described_class.new(delivery_info, nil, {'id' => 1, 'data' => {'foo' => 'bar'}})
    expect(payload.identify_by).to eq({'multiple_man_identifier' => 1})
  end

  it 'should store data appropriately' do
    expect(payload['id']).to eq(1)
    expect(payload['database']).to eq('app')
    expect(payload['foo']).to eq('bar')
  end

  it "should have an operation" do
    expect(payload.operation).to eq('create')
  end

  it "should let payloads override the operation" do
    payload = described_class.new(delivery_info, nil, { 'operation' => 'update' })
    expect(payload.operation).to eq('update')
  end
end
