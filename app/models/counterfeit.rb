# frozen_string_literal: true

class Counterfeit < Notice
  before_save :set_jurisdiction
  define_elasticsearch_mapping

  DEFAULT_ENTITY_NOTICE_ROLES = (BASE_ENTITY_NOTICE_ROLES |
                                %w[recipient sender principal]).freeze

  def self.model_name
    Notice.model_name
  end

  def self.label
    'Counterfeit'
  end

  def to_partial_path
    'notices/notice'
  end

  # The jurisdiction for a counterfeit notice should be the country of the
  # brand owner, who is the principal if present and the sender otherwise.
  def set_jurisdiction
    jurisdiction_list = [principal&.country_code] || [sender.country_code]
  end
end
