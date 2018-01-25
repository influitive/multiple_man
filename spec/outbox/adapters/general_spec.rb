require 'spec_helper'

describe 'Outbox::Adapters::General' do
  before(:each) do
    setup_db
  end

  after(:each) do
    clear_db
  end

  let(:subject) { MultipleMan::Outbox::Adapters::General }

  it 'can create/delete message' do
    create_messages(1)

    expect(subject.all.count).to eq(1)

    subject.last.delete

    expect(subject.all.count).to eq(0)
  end
end
