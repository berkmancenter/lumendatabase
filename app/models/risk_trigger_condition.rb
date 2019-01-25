class RiskTriggerCondition < ActiveRecord::Base
  ALLOWED_FIELDS = %w[
    title subject source tag_list language jurisdiction_list action_taken body
    type
    submitter.name submitter.kind submitter.address_line_1
    submitter.address_line_2 submitter.city submitter.state submitter.zip
    submitter.country_code submitter.phone submitter.email submitter.url
    recipient.name recipient.kind recipient.address_line_1
    recipient.address_line_2 recipient.city recipient.state recipient.zip
    recipient.country_code recipient.phone recipient.email recipient.url
    principal.name principal.kind principal.address_line_1
    principal.address_line_2 principal.city principal.state principal.zip
    principal.country_code principal.phone principal.email principal.url
    sender.name sender.kind sender.address_line_1
    sender.address_line_2 sender.city sender.state sender.zip
    sender.country_code sender.phone sender.email sender.url
  ].freeze

  ALLOWED_MATCHING_TYPES = %w[exact broad].freeze

  belongs_to :risk_trigger

  validates_presence_of :field, :value
  validates_inclusion_of :field, in: ALLOWED_FIELDS
  validates_inclusion_of :matching_type, in: ALLOWED_MATCHING_TYPES

  def risky?(notice)
    field_present?(notice) && condition_matches?(notice)
  rescue NoMethodError => ex
    Rails.logger.warn "Invalid risk trigger condition (#{id}): #{ex}"
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
    field.split('.').inject(notice, :send)
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
