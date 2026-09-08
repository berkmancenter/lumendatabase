# frozen_string_literal: true

# Submissions used to stage their attachments as Active Storage blobs. They are
# now stored as ordinary Paperclip file uploads, owned by the submission until
# the worker hands them to the notice it creates.
class MoveSubmissionUploadsToFileUploads < ActiveRecord::Migration[7.2]
  RETRY_SCHEDULE_INDEX = 'idx_submission_requests_on_retry_schedule'

  def up
    add_reference :file_uploads, :notice_submission_request, foreign_key: true
    drop_table :notice_submission_uploads

    # Staging can no longer fail on its own, so that status is gone.
    execute <<~SQL.squish
      UPDATE notice_submission_requests
      SET status = 'failed'
      WHERE status = 'staging_failed'
    SQL
    swap_retry_schedule_index("status IN ('received', 'failed')")
  end

  def down
    swap_retry_schedule_index(
      "status IN ('received', 'staging_failed', 'failed')"
    )

    create_table :notice_submission_uploads do |t|
      t.references :notice_submission_request,
                   null: false,
                   foreign_key: true,
                   index: { name: 'idx_notice_submission_uploads_on_request_id' }
      t.string :parameter_key, null: false
      t.string :kind
      t.string :original_filename, null: false
      t.string :content_type, null: false
      t.bigint :byte_size, null: false
      t.string :checksum, null: false

      t.timestamps
    end

    add_index :notice_submission_uploads,
              [:notice_submission_request_id, :parameter_key],
              unique: true,
              name: 'idx_notice_submission_uploads_on_request_and_key'
    remove_reference :file_uploads, :notice_submission_request, foreign_key: true
  end

  private

  # The table only holds submissions that have not been processed yet, so this
  # is small enough to rebuild in place.
  def swap_retry_schedule_index(statuses)
    remove_index :notice_submission_requests, name: RETRY_SCHEDULE_INDEX
    add_index :notice_submission_requests,
              [:status, :next_attempt_at],
              name: RETRY_SCHEDULE_INDEX,
              where: "#{statuses} AND attempts < 25"
  end
end
