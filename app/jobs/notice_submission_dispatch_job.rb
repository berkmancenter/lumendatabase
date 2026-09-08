# frozen_string_literal: true

class NoticeSubmissionDispatchJob < ApplicationJob
  queue_as :default

  def perform
    NoticeSubmissionRequest.dispatchable.find_each do |submission_request|
      submission_request.mark_queued!
      NoticeSubmissionJob.perform_later(submission_request.id)
    rescue StandardError => error
      Rails.logger.error(
        "Could not enqueue notice submission #{submission_request.id}: " \
        "#{error.class}: #{error.message}"
      )
    end
  end
end
