class RiskTriggerCondition < ApplicationRecord
  ALLOWED_FIELDS = (
    Notice.attribute_names.map { |field| 'notice.' + field } +
    Entity.attribute_names.map do |field|
      %w[submitter recipient principal sender].map do |entity|
        entity + '.' + field
      end
    end.flatten
  ).freeze

  ALLOWED_MATCHING_TYPES = %w[exact broad].freeze

  belongs_to :risk_trigger

  validates_presence_of :field, :value
  validates_inclusion_of :field, in: ALLOWED_FIELDS
  validates_inclusion_of :matching_type, in: ALLOWED_MATCHING_TYPES

  def risky?(notice)
    field_present?(notice) && condition_matches?(notice)
  rescue NoMethodError => ex
    Rails.logger.warn 'Invalid risk trigger condition (trigger condition ' \
                      "id:#{id}, notice id: #{notice.id}): #{ex}"
    false
  end

  private

  def field_present?(notice)
    notice_field_value(notice).present?
  end

  def condition_matches?(notice)
    notice_field_value = notice_field_value(notice)

    if matching_type == 'exact'
      match_exact(notice_field_value)
    else
      match_broad(notice_field_value)
    end
  end

  def notice_field_value(notice)
    field.gsub('notice.', '').split('.').inject(notice, :send)
  end

  def match_exact(notice_field_value)
    if negated?
      notice_field_value != value
    else
      notice_field_value == value
    end
  end

  def match_broad(notice_field_value)
    if negated?
      !notice_field_value.include?(value)
    else
      notice_field_value.include?(value)
    end
  end
end
