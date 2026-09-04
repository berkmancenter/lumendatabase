namespace :lumen do
  desc 'Enqueue notice submissions that were not completed'
  task enqueue_pending_notice_submissions: :environment do
    NoticeSubmissionDispatchJob.perform_now
  end
end
