require 'spec_helper'

describe FileUpload do
  it { should have_attached_file(:file) }
  it { should belong_to :notice }
  it { should have_db_index :notice_id }
  context 'schema_validations' do
    it { should ensure_length_of(:kind).is_at_most(255) }
  end
end
