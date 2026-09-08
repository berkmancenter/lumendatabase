namespace :lumen do
  desc 'Enqueue notice submissions that were not completed'
  task enqueue_pending_notice_submissions: :environment do
    NoticeSubmissionDispatchJob.perform_now
  end

  desc 'Discard payloads retained by completed submissions'
  task cleanup_completed_notice_submissions: :environment do
    completed = NoticeSubmissionRequest.where(status: 'completed')
    cleared_payloads = 0

    completed.where.not(payload: {}).in_batches(of: 1_000) do |batch|
      cleared_payloads += batch.update_all(
        payload: {},
        updated_at: Time.current
      )
    end

    puts "Cleared #{cleared_payloads} payloads"
  end
end
