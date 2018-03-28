require 'spec_helper'

describe 'Outbox::Message::Sequel' do
  before(:each) do
    setup_db
  end

  after(:each) do
    clear_db
  end

  let(:subject) { MultipleMan::Outbox::Message::Sequel }

  it 'can create/delete message' do
    create_messages(1)

    expect(subject.all.count).to eq(1)

    subject.last.delete

    expect(subject.all.count).to eq(0)
  end

  it '#in_groups yields messages ordered by set name' do
    create_messages(40)

    expected_ids = subject.order_by(:set_name, :id).all.map(&:id)
    result = []

    subject.in_groups_and_delete do |messages|
      messages.each { |m| result << m[:id] }
    end

    expect(subject.all.count).to eq(0)
    expect(expected_ids).to eq(result)
  end
end
