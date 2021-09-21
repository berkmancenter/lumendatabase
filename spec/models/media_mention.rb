require 'spec_helper'

describe MediaMention, type: :model do
  it { is_expected.to validate_presence_of :scale_of_mention }
end
