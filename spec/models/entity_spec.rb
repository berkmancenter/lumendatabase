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

  context 'redaction' do
    it 'redacts phone numbers with auto_redact' do
      content = '(617) 867-5309'
      test_redaction(content)
    end

    it 'redacts emails with auto_redact' do
      content = 'me@example.com'
      test_redaction(content)
    end

    it 'redacts SSNs with auto_redact' do
      content = '123-45-6789'
      test_redaction(content)
    end

    it 'redacts automatically on save' do
      params = { name: 'Test' }
      entity = Entity.new(params)
      expect(entity).to receive(:force_redactions)
      entity.save
    end
  end

  context 'validating scoped name attribute' do
    params = {
      title: 'A title',
      type: 'DMCA',
      date_sent: '2013-05-22',
      date_received: '2013-05-23',
      works_attributes: [
        {
          description: 'The Lion King on YouTube',
          infringing_urls_attributes: [
            {
              url: 'https://example.com'
            }
          ]
        }
      ],
      entity_notice_roles_attributes: [
        {
          name: 'recipient',
          entity_attributes: {
            name: 'Google'
          }
        },
        {
          name: 'sender',
          entity_attributes: {
            name: 'The Sender'
          }
        }
      ]
    }

    it 'doesn\'t validate a name of an existing entity when a duplicated entity is used but not updated' do
      create_duplicated_entity

      n = Notice.new(params)

      expect(n.valid?).to eq true
    end
  end

  it_behaves_like 'an object with hierarchical relationships'

  private

  def entity_for_redaction_testing(redact_me)
    params = { name: "Test if we redact #{redact_me}" }
    entity = Entity.new(params)
    entity.save
    entity.reload
    entity
  end

  def test_redaction(content)
    entity = entity_for_redaction_testing(content)

    expect(entity.name).not_to include content
    expect(entity.name_original).to include content
  end

  def create_duplicated_entity
    2.times do
      e = Entity.new(name: 'The Sender')
      e.save(validate: false)
    end
  end
end
