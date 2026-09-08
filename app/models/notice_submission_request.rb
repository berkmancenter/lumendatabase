# frozen_string_literal: true

class NoticeSubmissionRequest < ApplicationRecord
  MAX_ATTEMPTS = 25
  PROCESSING_TIMEOUT = 1.hour
  RETRY_BASE_DELAY = 1.minute
  RETRY_MAX_DELAY = 6.hours
  DISPATCHABLE_STATUSES = %w[received staging_failed failed].freeze
  STATUSES = %w[
    received queued staging_failed pending processing completed failed
  ].freeze

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
    now = Time.current

    where(attempts: ...MAX_ATTEMPTS).where(
      <<~SQL.squish,
        (
          status IN (:statuses)
          AND (next_attempt_at IS NULL OR next_attempt_at <= :now)
        ) OR (
          status = 'processing'
          AND started_at < :processing_timeout
        )
      SQL
      statuses: DISPATCHABLE_STATUSES,
      now: now,
      processing_timeout: now - PROCESSING_TIMEOUT
    )
  }

  def completed?
    status == 'completed'
  end

  def failed?
    %w[staging_failed failed].include?(status)
  end

  def processing?
    %w[received queued pending processing].include?(status)
  end

  def retryable?
    attempts < MAX_ATTEMPTS
  end

  def notice
    Notice.find_by(id: reserved_notice_id)
  end

  def dispatchable_now?(now = Time.current)
    return false unless retryable?

    if status == 'processing'
      return started_at.present? && started_at < now - PROCESSING_TIMEOUT
    end

    DISPATCHABLE_STATUSES.include?(status) &&
      (next_attempt_at.nil? || next_attempt_at <= now)
  end

  def begin_processing!
    started = false

    with_lock do
      if %w[received queued pending].include?(status)
        update!(
          status: 'processing',
          started_at: Time.current,
          failed_at: nil,
          failure_class: nil,
          failure_message: nil
        )
        started = true
      end
    end

    started
  end

  def mark_failed!(error)
    record_failure!('failed', error)
  end

  def mark_staging_failed!(error)
    record_failure!('staging_failed', error)
  end

  private

  def record_failure!(failure_status, error)
    # A processor transaction can leave this instance with rolled-back changes.
    # Active Record refuses to lock a dirty record, so restore the persisted
    # receipt before taking the failure-recording lock.
    reload
    with_lock do
      return if completed?

      attempt_count = attempts + 1
      update!(
        status: failure_status,
        attempts: attempt_count,
        failed_at: Time.current,
        failure_class: error.class.name,
        failure_message: error.message.to_s.truncate(2_000),
        next_attempt_at: next_attempt_at_for(attempt_count)
      )
    end
  end

  def next_attempt_at_for(attempt_count)
    return if attempt_count >= MAX_ATTEMPTS

    exponent = [attempt_count - 1, 12].min
    delay = [RETRY_BASE_DELAY * (2**exponent), RETRY_MAX_DELAY].min
    Time.current + delay + (id % 30).seconds
  end
end
