class AddReviewerIdToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :reviewer_id, :integer)
    add_index(:notices, :reviewer_id)
  end
end
