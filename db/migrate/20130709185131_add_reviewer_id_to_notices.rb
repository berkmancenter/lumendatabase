class AddReviewerIdToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :reviewer_id, :integer)
    add_index(:notices, :reviewer_id)
  end
end
