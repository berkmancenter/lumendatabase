require 'spec_helper'

RSpec.describe DataProtection, type: :model do
  it 'has the expected entity notice roles' do
    expected = %w[recipient submitter]
    expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES).to match_array expected
  end

  it 'has the expected partial path' do
    notice = create(:data_protection)
    expect(notice.to_partial_path).to eq 'notices/notice'
  end

  it 'has the right model name' do
    expect(described_class.model_name).to eq 'Notice'
  end
end
