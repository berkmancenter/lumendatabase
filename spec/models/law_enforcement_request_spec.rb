require 'spec_helper'

describe LawEnforcementRequest, type: :model do
  it {
    is_expected.to validate_inclusion_of(:request_type)
      .in_array(described_class::VALID_REQUEST_TYPES).allow_blank(true)
  }

  it 'has additional entities' do
    notice = create(
      :court_order,
      role_names: %w[recipient sender principal issuing_court plaintiff
                     defendant]
    )
    expect(notice.other_entity_notice_roles.map(&:name)).to match_array(
      %w[defendant issuing_court plaintiff principal]
    )
  end

  it 'has the expected entity notice roles' do
    expected = %w[recipient sender principal submitter]
    expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES).to match_array expected
  end

  it 'has the expected partial path' do
    notice = create(:law_enforcement_request)
    expect(notice.to_partial_path).to eq 'notices/notice'
  end

  it 'has the right model name' do
    expect(described_class.model_name).to eq 'Notice'
  end
end
