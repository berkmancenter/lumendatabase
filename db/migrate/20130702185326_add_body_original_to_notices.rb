class AddBodyOriginalToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :body_original, :text)
  end
end
