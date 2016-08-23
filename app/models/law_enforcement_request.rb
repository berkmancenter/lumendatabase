class LawEnforcementRequest < Notice

  DEFAULT_ENTITY_NOTICE_ROLES = %w|recipient sender principal|
  acts_as_taggable_on :regulations

  define_elasticsearch_mapping

  VALID_REQUEST_TYPES = [
    'Agency',
    'Civil Subpoena',
    'Email',
    'Records Preservation',
    'Subpoena',
    'Warrant',
  ]

  validates_inclusion_of :request_type,
    in: VALID_REQUEST_TYPES, allow_blank: true

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end

  def regulation_list
    tag_ids = self.taggings.where(context: 'regulations').pluck(:tag_id)
    ActsAsTaggableOn::Tag.find(tag_ids)
  end
end
