namespace :lumen do
  desc 'Enqueue notice submissions that were not completed'
  task enqueue_pending_notice_submissions: :environment do
    NoticeSubmissionDispatchJob.perform_now
  end

  desc 'Discard payloads and staged uploads retained by completed submissions'
  task cleanup_completed_notice_submissions: :environment do
    completed = NoticeSubmissionRequest.where(status: 'completed')
    cleared_payloads = 0

    completed.where.not(payload: {}).in_batches(of: 1_000) do |batch|
      cleared_payloads += batch.update_all(
        payload: {},
        updated_at: Time.current
      )
    end

    purged_uploads = 0
    NoticeSubmissionUpload
      .joins(:notice_submission_request)
      .where(notice_submission_requests: { status: 'completed' })
      .find_each do |upload|
        upload.destroy!
        purged_uploads += 1
      end

    puts "Cleared #{cleared_payloads} payloads and #{purged_uploads} uploads"
  end
end
