class AddReviewRequiredToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :review_required, :boolean)
  end
end
