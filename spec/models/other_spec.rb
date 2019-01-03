require 'spec_helper'

RSpec.describe Other, type: :model do
  it 'has the expected entity notice roles' do
    expected = %w[recipient sender submitter]
    expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES).to match_array expected
  end

  it 'has the expected partial path' do
    notice = create(:other)
    expect(notice.to_partial_path).to eq 'notices/notice'
  end

  it 'has the right model name' do
    expect(described_class.model_name).to eq 'Notice'
  end

  it 'hides identities when the recipient is google' do
    recipient_name = 'Google'
    notice = create(:other, :with_facet_data)
    notice.recipient.name = recipient_name
    notice.recipient.save

    expect(notice.hide_identities?).to be true

    recipient_name = 'Google, Inc.'
    notice.recipient.name = recipient_name
    notice.recipient.save

    expect(notice.hide_identities?).to be true

    recipient_name = 'Google LLC'
    notice.recipient.name = recipient_name
    notice.recipient.save

    expect(notice.hide_identities?).to be true
  end

  it 'hides sender names when hide_identities is true' do
    notice = create(:other)
    allow(notice).to receive(:hide_identities?).and_return(true)
    expect(notice.sender_name).to eq described_class::MASK
  end

  it 'hides principal names when hide_identities is true' do
    notice = create(:other)
    allow(notice).to receive(:hide_identities?).and_return(true)
    expect(notice.principal_name).to eq described_class::MASK
  end

  it 'shows sender names when hide_identities is false' do
    notice = create(:other)
    allow(notice).to receive(:hide_identities?).and_return(true)
    expect(notice.sender_name).to eq described_class::MASK
  end

  it 'shows principal names when hide_identities is false' do
    notice = create(:other)
    allow(notice).to receive(:hide_identities?).and_return(true)
    expect(notice.principal_name).to eq described_class::MASK
  end
end
