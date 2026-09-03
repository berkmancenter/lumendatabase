# frozen_string_literal: true

require 'lumen/models'
require 'lumen/models/validates_automatically'
require 'lumen/models'
require 'lumen/models/hierarchical_relationships'

class Entity < ApplicationRecord
  include Lumen::Models::ValidatesAutomatically
  include Lumen::Models::HierarchicalRelationships
  include Elasticsearch::Model
  include Lumen::Search::Searchability

  # == Constants ============================================================
  PER_PAGE = 10
  HIGHLIGHTS = %i[name].freeze
  DO_NOT_INDEX = %w[id name_original]
  KINDS = %w[organization individual].freeze
  INACTIVITY_NOTIFICATION_ATTRIBUTES = %w[
    inactivity_notification_emails
    inactivity_notification_after_hours
    inactivity_notification_sent_at
  ].freeze
  ADDITIONAL_DEDUPLICATION_FIELDS =
    %i[address_line_1 city state zip country_code phone email].freeze
  MULTI_MATCH_FIELDS = %w(name^5 kind address_line_1 address_line_2 state
    country_code^2 email url^3 ancestry city zip created_at updated_at)
  REDACTABLE_FIELDS = %w[name address_line_1 address_line_2 city state country_code url].freeze

  # == Relationships ========================================================
  has_many :users
  has_many :entity_notice_roles, dependent: :destroy
  has_many :notices, through: :entity_notice_roles
  has_many :submission_roles,
           -> { where(name: 'submitter') },
           class_name: 'EntityNoticeRole'
  has_many :submitted_notices,
           through: :submission_roles,
           source: :notice
  has_and_belongs_to_many :full_notice_only_researchers_users,
                          join_table: :entities_full_notice_only_researchers_users,
                          class_name: 'User'

  # == Extensions ===========================================================
  load_elasticsearch_helpers

  # == Validations ==========================================================
  validates :address_line_1, length: { maximum: 255 }
  validates_inclusion_of :kind, in: KINDS
  validates :inactivity_notification_after_hours,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil: true
  validate :inactivity_notification_settings_are_complete
  validate :inactivity_notification_emails_are_valid

  # == Callbacks ============================================================
  # Force search reindex on related notices
  after_update do
    unless inactivity_notification_changes_only?
      NoticeUpdateCall.create!(caller_id: self.id, caller_type: 'entity')
    end
  end
  after_validation :force_redactions
  before_save :reset_inactivity_notification_sent_at,
              if: :will_save_change_to_inactivity_notification_settings?

  # == Class Methods ========================================================
  def self.submitters
    submitter_ids = EntityNoticeRole.submitters.map(&:entity_id)

    where(id: submitter_ids)
  end

  # == Instance Methods =====================================================
  def as_indexed_json(_options)
    out = as_json(except: INACTIVITY_NOTIFICATION_ATTRIBUTES)

    out[:class_name] = 'entity'

    out
  end

  def attributes_for_deduplication
    all_deduplication_attributes = [
      :name, ADDITIONAL_DEDUPLICATION_FIELDS
    ].flatten

    instance_clone = self.dup
    instance_clone.force_redactions

    instance_clone.attributes.select do |key, _value|
      all_deduplication_attributes.include?(key.to_sym)
    end
  end

  def force_redactions
    # We don't want to ever redact entities linked with users with the submitter role
    return if submitter_user_entity?

    Lumen::InstanceRedactor.new.redact(self, REDACTABLE_FIELDS)
  end

  def submitter_user_entity?
    self.users.joins(:roles).where(roles: { name: 'submitter' }).any?
  end

  def publication_delay
    self.users.first&.publication_delay || 0
  end

  def inactivity_notification_recipients
    inactivity_notification_emails
      .to_s
      .split(/[,\r\n]+/)
      .map(&:strip)
      .reject(&:blank?)
  end

  def inactivity_notifications_enabled?
    inactivity_notification_recipients.any? &&
      inactivity_notification_after_hours.present?
  end

  def latest_submission_at
    submitted_notices.maximum(:created_at)
  end

  def inactivity_notification_due?(now = Time.current, last_submission_at: latest_submission_at)
    return false unless inactivity_notifications_enabled?
    return false if last_submission_at.blank?
    return false if last_submission_at > inactivity_notification_after_hours.hours.ago(now)
    return true if inactivity_notification_sent_at.blank?

    inactivity_notification_sent_at < last_submission_at
  end

  private

  def inactivity_notification_settings_are_complete
    if inactivity_notification_emails.present? && inactivity_notification_after_hours.blank?
      errors.add(:inactivity_notification_after_hours, 'must be set when notification addresses are present')
    elsif inactivity_notification_emails.blank? && inactivity_notification_after_hours.present?
      errors.add(:inactivity_notification_emails, 'must be set when an inactivity period is present')
    end
  end

  def inactivity_notification_emails_are_valid
    return if inactivity_notification_emails.blank?

    recipients = inactivity_notification_recipients
    if recipients.empty?
      errors.add(:inactivity_notification_emails, 'must include at least one email address')
      return
    end

    invalid_recipients = recipients.reject do |recipient|
      URI::MailTo::EMAIL_REGEXP.match?(recipient)
    end
    return if invalid_recipients.empty?

    errors.add(
      :inactivity_notification_emails,
      "contains invalid addresses: #{invalid_recipients.join(', ')}"
    )
  end

  def will_save_change_to_inactivity_notification_settings?
    will_save_change_to_inactivity_notification_emails? ||
      will_save_change_to_inactivity_notification_after_hours?
  end

  def inactivity_notification_changes_only?
    changed_attributes = saved_changes.keys
    notification_attributes_changed = (
      changed_attributes & INACTIVITY_NOTIFICATION_ATTRIBUTES
    ).any?
    other_attributes_changed = changed_attributes -
                               INACTIVITY_NOTIFICATION_ATTRIBUTES -
                               ['updated_at']

    notification_attributes_changed && other_attributes_changed.empty?
  end

  def reset_inactivity_notification_sent_at
    self.inactivity_notification_sent_at = nil
  end
end
