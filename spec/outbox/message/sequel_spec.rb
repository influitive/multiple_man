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

  it '#in_batches yields messages' do
    create_messages(4)

    expected_ids = subject.all.map(&:id)
    result = []

    subject.in_batches_and_delete(2) do |messages|
      messages.each { |m| result << m.id }
    end

    expect(subject.all.count).to eq(0)
    expect(expected_ids).to eq(result)
  end
end
