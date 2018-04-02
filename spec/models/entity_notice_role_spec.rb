require 'rails_helper'
require 'spec_helper'

describe EntityNoticeRole, type: :model do
  it { is_expected.to belong_to :entity }
  it { is_expected.to belong_to :notice }

  context 'automatic validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
  end

  it { is_expected.to validate_presence_of :entity }
  it { is_expected.to validate_presence_of :notice }

  it { is_expected.to have_db_index :entity_id }
  it { is_expected.to have_db_index :notice_id }
  it { is_expected.to validate_inclusion_of(:name).in_array(EntityNoticeRole::ROLES) }

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
      entity_notice_role_with_entity_attrs do |existing_entity, entity_notice_role|

        entity_notice_role.save
        entity_notice_role.reload

        expect(entity_notice_role.entity).to eq existing_entity
      end
    end

    it "creates additional entities when fields vary only slightly" do
      entity_notice_role_with_entity_attrs(state: 'CA') do |existing_entity, entity_notice_role|

        entity_notice_role.save
        entity_notice_role.reload

        expect(entity_notice_role.entity).not_to eq existing_entity
      end
    end

    it "validates entities correctly when multiple are used at once" do
      notice = notice_with_roles_attributes([
        { name: 'recipient', entity_attributes: { name: "" } },
        { name: 'submitter', entity_attributes: { name: "" } }
      ])

      expect(notice).not_to be_valid
      expect(notice.errors.messages).to eq(
        { :"entity_notice_roles.entity" => ["is invalid"] }
      )
    end
  end

  private

  def entity_notice_role_with_entity_attrs(attr_overrides = {})
    existing_entity = create(
      :entity, entity_attributes
    )
    duplicate_entity = build(
      :entity, entity_attributes.merge(attr_overrides)
    )

    entity_notice_role = create(:entity_notice_role, entity: duplicate_entity, notice: build(:dmca))
    yield existing_entity, entity_notice_role
  end

  def notice_with_roles_attributes(attributes)
    DMCA.new(
      entity_notice_roles_attributes: attributes,
      works: build_list(:work, 2) # to make it valid otherwise
    )
  end

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
