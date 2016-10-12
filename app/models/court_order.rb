class CourtOrder < Notice

  DEFAULT_ENTITY_NOTICE_ROLES = %w|recipient sender principal issuing_court plaintiff defendant|
  acts_as_taggable_on :regulations

  define_elasticsearch_mapping

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end

  def laws_referenced
    tag_ids = self.taggings.where(context: 'regulations').pluck(:tag_id)
    ActsAsTaggableOn::Tag.find(tag_ids)
  end
end
