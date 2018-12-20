require 'spec_helper'

RSpec.describe DataProtection, type: :model do
  it 'has the expected entity notice roles' do
    expected = %w[recipient submitter]
    expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES).to match_array expected
  end
end
