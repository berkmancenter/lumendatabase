class AddBodyOriginalToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :body_original, :text)
  end
end
