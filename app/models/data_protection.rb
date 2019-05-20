# frozen_string_literal: true

class DataProtection < Notice
  DEFAULT_ENTITY_NOTICE_ROLES = (BASE_ENTITY_NOTICE_ROLES |
                                 %w[recipient]).freeze

  define_elasticsearch_mapping

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end
end
