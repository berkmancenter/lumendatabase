require 'spec_helper'

describe EntityNoticeRole do
  it { should belong_to :entity }
  it { should belong_to :notice }

  context 'automatic validations' do
    it { should validate_presence_of :name }
    it { should ensure_length_of(:name).is_at_most(255) }
  end

  it { should validate_presence_of :entity }
  it { should validate_presence_of :notice }

  it { should have_db_index :entity_id }
  it { should have_db_index :notice_id }
  it { should ensure_inclusion_of(:name).in_array(EntityNoticeRole::ROLES) }

  EntityNoticeRole::ROLES.each do |role|
    context "getting #{role} instances" do
      it 'returns the correct role' do
        create(:dmca, role_names: [role, a_different_role_than(role)])

        expect(described_class.all.count).to eq 2
        expect(described_class.send(role.pluralize.to_sym).count).to eq 1
      end
    end
  end

  context '#entities' do
    it "does not create duplicate entities" do
      existing_entity = create(
        :entity, entity_attributes
      )
      duplicate_entity = build(
        :entity, entity_attributes
      )

      entity_notice_role = build(
        :entity_notice_role, entity: duplicate_entity, notice: build(:dmca)
      )
      entity_notice_role.save

      entity_notice_role.reload

      expect(entity_notice_role.entity).to eq existing_entity
    end
  end

  private

  def entity_attributes
    {
      name: 'Foo bar corp',
      address_line_1: '123 foo lane',
      city: 'Fooville',
      state: 'MA',
      zip: '01922'
    }
  end

  def a_different_role_than(role)
    roles = EntityNoticeRole::ROLES.dup
    roles.delete(role)
    roles.first
  end

end
