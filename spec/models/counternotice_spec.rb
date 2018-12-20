require 'rails_helper'

describe Counternotice, type: :model do
  it { is_expected.to validate_presence_of :entity_notice_roles }

  it 'has the expected entity notice roles' do
    expected = %w[recipient sender principal submitter]
    expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES).to match_array expected
  end
end
