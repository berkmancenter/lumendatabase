require 'spec_helper'

RSpec.describe Defamation, type: :model do
  it 'has the expected entity notice roles' do
    expected = %w[recipient sender submitter]
    expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES).to match_array expected
  end

  it 'has the expected partial path' do
    notice = create(:defamation)
    expect(notice.to_partial_path).to eq 'notices/notice'
  end

  it 'has the right model name' do
    expect(described_class.model_name).to eq 'Notice'
  end

  it 'hides identities when the recipient is google' do
    recipient_name = 'Google'
    defamation = create(:defamation, :with_facet_data)
    defamation.recipient.name = recipient_name
    defamation.recipient.save

    expect(defamation.hide_identities?).to be true

    recipient_name = 'Google, Inc.'
    defamation.recipient.name = recipient_name
    defamation.recipient.save

    expect(defamation.hide_identities?).to be true

    recipient_name = 'Google LLC'
    defamation.recipient.name = recipient_name
    defamation.recipient.save

    expect(defamation.hide_identities?).to be true
  end

  it 'hides sender names when hide_identities is true' do
    defamation = create(:defamation)
    allow(defamation).to receive(:hide_identities?).and_return(true)
    expect(defamation.sender_name).to eq described_class::MASK
  end

  it 'hides principal names when hide_identities is true' do
    defamation = create(:defamation)
    allow(defamation).to receive(:hide_identities?).and_return(true)
    expect(defamation.principal_name).to eq described_class::MASK
  end

  it 'shows sender names when hide_identities is false' do
    defamation = create(:defamation)
    allow(defamation).to receive(:hide_identities?).and_return(true)
    expect(defamation.sender_name).to eq described_class::MASK
  end

  it 'shows principal names when hide_identities is false' do
    defamation = create(:defamation)
    allow(defamation).to receive(:hide_identities?).and_return(true)
    expect(defamation.principal_name).to eq described_class::MASK
  end
end
