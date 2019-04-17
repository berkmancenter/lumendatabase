require 'spec_helper'

describe DocumentsUpdateNotificationNotice, type: :model do
  it { is_expected.to belong_to(:notice) }
  it { is_expected.to validate_presence_of :notice }
end
