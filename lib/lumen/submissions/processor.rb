# frozen_string_literal: true

class Lumen::Submissions::Processor
  def initialize(submission_request)
    @submission_request = submission_request
  end

  def process
    submission_request.with_lock do
      return submission_request.notice if submission_request.completed?

      if (existing_notice = submission_request.notice)
        mark_completed!(existing_notice)
        return existing_notice
      end

      submission_request.update!(status: 'processing', started_at: Time.current)

      notice = Lumen::NoticeBuilder.new(
        notice_class,
        submission_request.payload.deep_dup,
        nil,
        submitter_entity: submission_request.submitter_entity
      ).build
      notice.id = submission_request.reserved_notice_id
      notice.file_uploads = claimed_file_uploads
      notice.save!
      notice.mark_for_review
      mark_completed!(notice)
      notice
    end
  end

  private

  attr_reader :submission_request

  def notice_class
    submission_request.notice_type.constantize.tap do |model_class|
      raise NameError, 'Invalid notice type' unless model_class < Notice
    end
  end

  # The submission holds the attachments only until its notice exists. Saving
  # the notice moves them across, and rolling back leaves them where they were.
  def claimed_file_uploads
    submission_request.file_uploads.to_a.each do |file_upload|
      file_upload.notice_submission_request = nil
    end
  end

  def mark_completed!(notice)
    # The payload is needed only while a receipt can retry.
    submission_request.file_uploads.reset
    submission_request.update!(
      status: 'completed',
      payload: {},
      attempts: submission_request.attempts + 1,
      completed_at: Time.current,
      next_attempt_at: nil,
      failed_at: nil,
      failure_class: nil,
      failure_message: nil
    )
    notice
  end
end
