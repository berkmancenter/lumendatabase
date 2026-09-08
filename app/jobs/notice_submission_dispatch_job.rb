# frozen_string_literal: true

class NoticeSubmissionDispatchJob < ApplicationJob
  queue_as :default

  def perform
    NoticeSubmissionRequest.dispatchable.select(:id).find_each do |request|
      Lumen::Submissions::Enqueuer.new(request.id).call
    rescue StandardError => error
      Rails.logger.error(
        "Could not enqueue notice submission #{request.id}: " \
        "#{error.class}: #{error.message}"
      )
    end
  end
end
