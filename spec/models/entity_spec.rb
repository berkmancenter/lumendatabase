require 'rails_helper'
require 'rake'

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
  it { is_expected.to have_many(:notices).through(:entity_notice_roles) }
  it { is_expected.to have_and_belong_to_many(:full_notice_only_researchers_users) }
  it { is_expected.to validate_inclusion_of(:kind).in_array(Entity::KINDS) }

  context '.submitters' do
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
    it 'updates updated_at for every notice associated with an entity' do
      notice = create(:dmca)

      notice.reload

      puts notice.inspect

      previous_updated_at = notice.updated_at
      entity = notice.entities.first
      entity.name = 'transparent change'
      entity.save

      notice.reload

      expect(notice.updated_at).to eq previous_updated_at

      Rake::Task['lumen:mark_notices_to_reindex_after_relations_update'].execute

      notice.reload

      expect(notice.updated_at).to be > previous_updated_at

      previous_updated_at = notice.updated_at

      entity.update(name: 'Updatey McUpdateface')

      Rake::Task['lumen:mark_notices_to_reindex_after_relations_update'].execute

      notice.reload

      expect(notice.updated_at).to be > previous_updated_at
    end
  end

  it_behaves_like 'an object with hierarchical relationships'
end
