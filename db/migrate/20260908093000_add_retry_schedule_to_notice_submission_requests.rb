# frozen_string_literal: true

class AddRetryScheduleToNoticeSubmissionRequests < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    add_column :notice_submission_requests, :next_attempt_at, :datetime
    change_column_default :notice_submission_requests,
                          :status,
                          from: 'pending',
                          to: 'received'

    # Before queued was a distinct state, pending meant that a job had already
    # been sent to Sidekiq. Preserve that meaning during a rolling deploy.
    execute <<~SQL.squish
      UPDATE notice_submission_requests
      SET status = 'queued'
      WHERE status = 'pending'
    SQL

    add_index :notice_submission_requests,
              [:status, :next_attempt_at],
              name: 'idx_submission_requests_on_retry_schedule',
              where: <<~SQL.squish,
                status IN ('received', 'staging_failed', 'failed')
                AND attempts < 25
              SQL
              algorithm: :concurrently
    add_index :notice_submission_requests,
              [:status, :started_at],
              name: 'idx_submission_requests_on_stale_processing',
              where: "status = 'processing' AND attempts < 25",
              algorithm: :concurrently
  end

  def down
    remove_index :notice_submission_requests,
                 name: 'idx_submission_requests_on_stale_processing',
                 algorithm: :concurrently
    remove_index :notice_submission_requests,
                 name: 'idx_submission_requests_on_retry_schedule',
                 algorithm: :concurrently

    execute <<~SQL.squish
      UPDATE notice_submission_requests
      SET status = 'pending'
      WHERE status = 'queued'
    SQL

    change_column_default :notice_submission_requests,
                          :status,
                          from: 'received',
                          to: 'pending'
    remove_column :notice_submission_requests, :next_attempt_at
  end
end
