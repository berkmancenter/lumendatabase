# frozen_string_literal: true

class Lumen::Submissions::Enqueuer
  LOCK_COLUMNS = %i[
    id status attempts next_attempt_at started_at
  ].freeze

  class EnqueueError < StandardError; end

  def initialize(submission_request_id)
    @submission_request_id = submission_request_id
  end

  def call
    enqueued = false

    NoticeSubmissionRequest.transaction do
      submission_request = locked_submission_request
      next unless submission_request&.dispatchable_now?

      now = Time.current
      submission_request.update_columns(
        status: 'queued',
        queued_at: now,
        next_attempt_at: nil,
        updated_at: now
      )
      enqueue_job(submission_request.id)
      enqueued = true
    end

    enqueued
  end

  private

  attr_reader :submission_request_id

  def locked_submission_request
    NoticeSubmissionRequest.select(LOCK_COLUMNS)
                           .lock('FOR UPDATE SKIP LOCKED')
                           .find_by(id: submission_request_id)
  end

  def enqueue_job(request_id)
    result = NoticeSubmissionJob.perform_later(request_id)
    return unless result == false

    raise EnqueueError, "Could not enqueue submission #{request_id}"
  end
end
