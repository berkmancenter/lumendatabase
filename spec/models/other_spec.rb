require 'spec_helper'

RSpec.describe Other, type: :model do
  it 'has the expected entity notice roles' do
    expected = %w[recipient sender submitter]
    expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES).to match_array expected
  end

  it 'has the expected partial path' do
    notice = build(:other)
    expect(notice.to_partial_path).to eq 'notices/notice'
  end

  it 'has the right model name' do
    expect(described_class.model_name).to eq 'Notice'
  end

  it 'hides identities when the recipient is google or youtube' do
    recipient_names = ['Google', 'Google, Inc.', 'Google LLC', 'YouTube LLC']
    notice = create(:other, :with_facet_data)

    recipient_names.each do |recipient_name|
      notice.recipient.name = recipient_name
      notice.auto_redact
      notice.recipient.save

      expect(notice.sender.name).to eq Lumen::REDACTION_MASK
    end
  end
end
