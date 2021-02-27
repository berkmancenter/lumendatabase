class AddIndexToNotices < ActiveRecord::Migration[4.2]
  def change
    add_index :notices, :created_at
  end
end
