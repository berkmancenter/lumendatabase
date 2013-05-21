require 'spec_helper'

describe FileUpload do
  it { should have_attached_file(:file) }
  it { should belong_to :notice }
  it { should have_db_index :notice_id }
end
