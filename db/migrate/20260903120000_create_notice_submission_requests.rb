class CreateNoticeSubmissionRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :notice_submission_requests do |t|
      # The notice is created later, so this intentionally cannot have a
      # foreign key to notices yet.
      t.integer :reserved_notice_id, null: false
      t.string :notice_type, null: false
      t.jsonb :payload, default: {}, null: false
      t.string :payload_digest, null: false
      t.references :submitted_by,
                   foreign_key: { to_table: :users, on_delete: :nullify }
      t.references :submitter_entity,
                   foreign_key: { to_table: :entities }
      t.string :status, default: 'pending', null: false
      t.string :request_id
      t.integer :attempts, default: 0, null: false
      t.datetime :queued_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :failed_at
      t.string :failure_class
      t.text :failure_message

      t.timestamps
    end

    add_index :notice_submission_requests, :reserved_notice_id, unique: true
    add_index :notice_submission_requests, :status

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
  end
end
