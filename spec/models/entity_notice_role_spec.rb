require 'spec_helper'

describe EntityNoticeRole do
  it { should belong_to :entity }
  it { should belong_to :notice }

  context 'schema_validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :entity }
    it { should validate_presence_of :notice }
    it { should ensure_length_of(:name).is_at_most(255) }
  end

  it { should have_db_index :entity_id }
  it { should have_db_index :notice_id }
  it { should ensure_inclusion_of(:name).in_array(EntityNoticeRole::ROLES) }

  EntityNoticeRole::ROLES.each do |role|
    context "getting #{role} instances" do
      it 'returns the correct role' do
        create(:notice, role_names: [role, a_different_role_than(role)])

        expect(described_class.all.count).to eq 2
        expect(described_class.send(role.pluralize.to_sym).count).to eq 1
      end
    end
  end

  private

  def a_different_role_than(role)
    roles = EntityNoticeRole::ROLES.dup
    roles.delete(role)
    roles.first
  end

end
