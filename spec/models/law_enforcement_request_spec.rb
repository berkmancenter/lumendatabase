require 'spec_helper'

describe LawEnforcementRequest, type: :model do
  it { is_expected.to validate_inclusion_of(:request_type).
    in_array(described_class::VALID_REQUEST_TYPES).allow_blank(true) }

  it "has additional entities" do
    notice = create(
      :court_order,
      role_names: %w|recipient sender principal issuing_court plaintiff defendant|
    )
    expect(notice.other_entity_notice_roles.map(&:name)).to match_array(
      %w|defendant issuing_court plaintiff principal|
    )
  end
end
