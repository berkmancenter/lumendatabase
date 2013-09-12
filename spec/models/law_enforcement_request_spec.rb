require 'spec_helper'

describe LawEnforcementRequest do
  it { should ensure_inclusion_of(:request_type).
    in_array(described_class::VALID_REQUEST_TYPES).allow_blank(true) }
end
