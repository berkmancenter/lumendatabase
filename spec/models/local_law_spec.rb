require 'spec_helper'

RSpec.describe LocalLaw, type: :model do
  it 'is its own notice type' do
    expect(described_class < Notice).to be true
    expect(described_class.ancestors).not_to include(Other)
  end

  it 'has the expected entity notice roles' do
    expected = %w[recipient sender submitter]
    expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES).to match_array expected
  end

  it 'has the expected partial path' do
    notice = build(:local_law)
    expect(notice.to_partial_path).to eq 'notices/notice'
  end

  it 'has the right model name' do
    expect(described_class.model_name).to eq 'Notice'
  end
end
