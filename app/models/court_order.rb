# frozen_string_literal: true

class CourtOrder < Notice
  DEFAULT_ENTITY_NOTICE_ROLES = (BASE_ENTITY_NOTICE_ROLES |
                                %w[recipient sender principal issuing_court
                                   plaintiff defendant]).freeze

  define_elasticsearch_mapping

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end

  def laws_referenced
    regulation_list
  end
end
