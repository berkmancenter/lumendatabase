require 'spec_helper'

RSpec.describe CourtOrder, type: :model do
  it 'has the expected entity notice roles' do
    expected = %w[recipient sender principal issuing_court
                  plaintiff defendant submitter]
    expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES).to match_array expected
  end
end
