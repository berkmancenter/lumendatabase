class AddStaleQueuedNoticeSubmissionIndex < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    add_index :notice_submission_requests,
              [:status, :queued_at],
              name: 'idx_submission_requests_on_stale_queued',
              where: "status = 'queued' AND attempts < 25",
              algorithm: :concurrently
  end

  def down
    remove_index :notice_submission_requests,
                 name: 'idx_submission_requests_on_stale_queued',
                 algorithm: :concurrently
  end
end
