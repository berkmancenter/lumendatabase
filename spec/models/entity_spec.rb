require "spec_helper"

describe Entity do
  context 'automatic validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :kind }
    it { should ensure_length_of(:address_line_1).is_at_most(255) }
  end

  context 'de-duplication' do
    it {
      should validate_uniqueness_of(:name).scoped_to(
        Entity::ADDITIONAL_DEDUPLICATION_FIELDS
      )
    }
  end

  it { should belong_to(:user) }
  it { should have_many(:entity_notice_roles).dependent(:destroy) }
  it { should have_many(:notices).through(:entity_notice_roles)  }
  it { should ensure_inclusion_of(:kind).in_array(Entity::KINDS) }

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
      EntityIndexQueuer.should_receive(:for).with(entity.id)

      entity.save
    end
  end

  it_behaves_like 'an object with hierarchical relationships'
end
