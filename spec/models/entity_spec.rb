require "rails_helper"

describe Entity, type: :model do
  context 'automatic validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :kind }
    it { is_expected.to validate_length_of(:address_line_1).is_at_most(255) }
  end

  context 'de-duplication' do
    Entity::ADDITIONAL_DEDUPLICATION_FIELDS.each do |field|
      it "de-duplicates across name and #{field}" do
        entity = create(:entity, name: 'Foobar', field => 'Something')

        other_entity = build(:entity, name: 'Foobar', field => 'Something')

        expect(other_entity).not_to be_valid
      end

      it "allows duplicate names with non-duplicate #{field}" do
        entity = create(:entity, name: 'Foobar', field => 'Something')

        other_entity = build(:entity, name: 'Foobar', field => 'Something else')

        expect(other_entity).to be_valid
      end
    end
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:entity_notice_roles).dependent(:destroy) }
  it { is_expected.to have_many(:notices).through(:entity_notice_roles)  }
  it { is_expected.to validate_inclusion_of(:kind).in_array(Entity::KINDS) }

  context ".submitters" do
    it "returns only submitter types" do
      create(:entity, entity_notice_roles: [
        build(:entity_notice_role, name: 'sender')
      ])
      entity = create(:entity, entity_notice_roles: [
        build(:entity_notice_role, name: 'submitter')
      ])

      entities = Entity.submitters

      expect(entities).to eq [entity]
    end
  end

  context 'post update reindexing' do
    it "uses the TopicIndexQueuer to schedule notices for indexing" do
      entity = create(:entity)
      expect(EntityIndexQueuer).to receive(:for).with(entity.id)

      entity.save
    end
  end

  it_behaves_like 'an object with hierarchical relationships'
end
