require 'spec_helper'

RSpec.describe CourtOrder, type: :model do
  it 'has the expected entity notice roles' do
    expected = %w[recipient sender principal issuing_court
                  plaintiff defendant submitter]
    expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES).to match_array expected
  end

  it 'has the expected partial path' do
    notice = create(:court_order)
    expect(notice.to_partial_path).to eq 'notices/notice'
  end

  it 'has the right model name' do
    expect(described_class.model_name).to eq 'Notice'
  end
end
