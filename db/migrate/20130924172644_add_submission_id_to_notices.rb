class AddSubmissionIdToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :submission_id, :integer

    add_index :notices, :submission_id
    add_index :notices, :original_notice_id
  end
end
