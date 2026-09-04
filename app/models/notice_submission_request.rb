# frozen_string_literal: true

class NoticeSubmissionRequest < ApplicationRecord
  MAX_ATTEMPTS = 25
  STATUSES = %w[received staging_failed pending processing completed failed].freeze

  belongs_to :submitted_by, class_name: 'User', optional: true
  belongs_to :submitter_entity, class_name: 'Entity', optional: true

  has_many :uploads,
           class_name: 'NoticeSubmissionUpload',
           dependent: :destroy,
           inverse_of: :notice_submission_request

  validates :attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :notice_type, presence: true, inclusion: { in: Lumen::TYPES }
  validates :payload, presence: true
  validates :payload_digest, presence: true
  validates :reserved_notice_id,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :dispatchable, lambda {
    where(
      status: %w[received staging_failed pending failed],
      attempts: ...MAX_ATTEMPTS
    )
      .where('queued_at IS NULL OR queued_at < ?', 5.minutes.ago)
  }

  def completed?
    status == 'completed'
  end

  def failed?
    %w[staging_failed failed].include?(status)
  end

  def processing?
    %w[received pending processing].include?(status)
  end

  def retryable?
    attempts < MAX_ATTEMPTS
  end

  def notice
    Notice.find_by(id: reserved_notice_id)
  end

  def mark_queued!
    update_column(:queued_at, Time.current)
  end

  def mark_failed!(error)
    record_failure!('failed', error)
  end

  def mark_staging_failed!(error)
    record_failure!('staging_failed', error)
  end

  private

  def record_failure!(failure_status, error)
    with_lock do
      update!(
        status: failure_status,
        attempts: attempts + 1,
        failed_at: Time.current,
        failure_class: error.class.name,
        failure_message: error.message.to_s.truncate(2_000)
      )
    end
  end
end
