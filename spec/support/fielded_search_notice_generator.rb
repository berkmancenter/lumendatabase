class FieldedSearchNoticeGenerator
  attr_reader :query, :matched_notice, :unmatched_notice

  def self.for(field)
    new(field).tap do |instance|
      instance.public_send(:"for_#{field.parameter}")
      instance.matched_notice.save!
      instance.unmatched_notice.save!
    end
  end

  def initialize(field)
    @field = field
    @query = "Something Specific"
    # Add 'field' to strings to make these more unique and keep tests from
    # contaminating one another.
    @matched_notice = FactoryBot.create(:dmca, title: "To Be Found #{field}")
    @unmatched_notice = FactoryBot.create(:dmca, title: "Not To Be Found #{field}")
  end

  def for_title
    matched_notice.title = query
    unmatched_notice.title = "N/A"
  end

  def for_sender_name
    for_role_name('sender')
  end

  def for_principal_name
    for_role_name('principal')
  end

  def for_recipient_name
    for_role_name('recipient')
  end

  def for_submitter_name
    for_role_name('submitter')
  end

  def for_submitter_country_code
    matched_notice.entity_notice_roles = [FactoryBot.build(
      :entity_notice_role, name: 'submitter',
      notice: matched_notice,
      entity: FactoryBot.build(:entity, country_code: query)
    )]
    unmatched_notice.entity_notice_roles = [FactoryBot.build(
      :entity_notice_role, name: 'submitter',
      notice: unmatched_notice,
      entity: FactoryBot.build(:entity, country_code: "N/A")
    )]
  end

  def for_tags
    matched_notice.tag_list = query
    unmatched_notice.tag_list = "N/A"
  end

  def for_jurisdictions
    matched_notice.jurisdiction_list = query
    unmatched_notice.jurisdiction_list = "N/A"
  end

  def for_topics
    matched_notice.topics = [FactoryBot.build(:topic, name: query)]
    unmatched_notice.topics = [FactoryBot.build(:topic, name: "N/A")]
  end

  def for_works
    matched_notice.works = [FactoryBot.build(:work, description: query)]
    unmatched_notice.works = [FactoryBot.build(:work, description: "N/A")]
  end

  def for_action_taken
    @query = "Yes"

    matched_notice.action_taken = query
    unmatched_notice.action_taken = "No"
  end

  def for_entities_country_codes
    matched_notice.entity_notice_roles = [FactoryBot.build(
      :entity_notice_role, name: 'sender',
      notice: matched_notice,
      entity: FactoryBot.build(:entity, name: 'Entity', country_code: query)
    )]
    unmatched_notice.entity_notice_roles = [FactoryBot.build(
      :entity_notice_role, name: 'sender',
      notice: unmatched_notice,
      entity: FactoryBot.build(:entity, name: 'Entity', country_code: 'N/A')
    )]
  end

  private

  def for_role_name(role_name)
    matched_notice.entity_notice_roles = [FactoryBot.build(
      :entity_notice_role, name: role_name,
      notice: matched_notice,
      entity: FactoryBot.build(:entity, name: query)
    )]
    unmatched_notice.entity_notice_roles = [FactoryBot.build(
      :entity_notice_role, name: role_name,
      notice: unmatched_notice,
      entity: FactoryBot.build(:entity, name: "N/A")
    )]
  end
end
