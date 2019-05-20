# frozen_string_literal: true

class DMCA < Notice
  define_elasticsearch_mapping

  DEFAULT_ENTITY_NOTICE_ROLES = (BASE_ENTITY_NOTICE_ROLES |
                                %w[recipient sender principal]).freeze

  validates :title, length: { maximum: 255 }

  def self.model_name
    Notice.model_name
  end

  def self.label
    'DMCA'
  end

  def to_partial_path
    'notices/notice'
  end
end
