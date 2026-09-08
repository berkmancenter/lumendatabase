# frozen_string_literal: true

class NoticeSubmissionJob < ApplicationJob
  queue_as :submissions
  # Receipt state and the cron dispatcher are the single retry authority.
  sidekiq_options retry: false
  self.enqueue_after_transaction_commit = :never

  def perform(submission_request_id)
    submission_request = NoticeSubmissionRequest.find(submission_request_id)
    return submission_request.notice unless submission_request.begin_processing!

    staging_attachments = true
    Lumen::Submissions::AttachmentStager.new(submission_request).stage
    staging_attachments = false
    Lumen::Submissions::Processor.new(submission_request).process
  rescue StandardError => error
    begin
      unless submission_request&.completed?
        if staging_attachments ||
           error.is_a?(Lumen::Submissions::Processor::StagedAttachmentError)
          submission_request&.mark_staging_failed!(error)
        else
          submission_request&.mark_failed!(error)
        end
      end
    rescue StandardError => recording_error
      Rails.logger.error(
        "Unable to record failure for submission #{submission_request_id}: " \
        "#{recording_error.class}: #{recording_error.message}"
      )
    end
    raise error
  end
end
