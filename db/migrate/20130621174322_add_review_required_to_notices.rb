class AddReviewRequiredToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :review_required, :boolean)
  end
end
