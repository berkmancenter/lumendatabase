require 'rails_helper'

describe Counternotice, type: :model do
  it { is_expected.to validate_presence_of :entity_notice_roles }
end
