require 'spec_helper'

describe EntityNoticeRole do
  it{ should belong_to :entity }
  it{ should belong_to :notice }
  it{ should validate_presence_of :name }
  it{ should validate_presence_of :entity }
  it{ should validate_presence_of :notice }
  it{ should have_db_index :entity_id }
  it{ should have_db_index :notice_id }
  it{ should ensure_inclusion_of(:name).in_array(EntityNoticeRole::ROLES) }
end
