require 'spec_helper'

describe NoticeImportError, type: :model do
  it { is_expected.to validate_length_of(:file_list).is_at_most(2.kilobytes) }
  it { is_expected.to validate_length_of(:message).is_at_most(16.kilobytes) }
  it { is_expected.to validate_length_of(:stacktrace).is_at_most(2.kilobytes) }
  it { is_expected.to validate_length_of(:import_set_name).is_at_most(1.kilobyte) }
end
