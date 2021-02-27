class AddSubmissionIdToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :submission_id, :integer

    add_index :notices, :submission_id
    add_index :notices, :original_notice_id
  end
end
