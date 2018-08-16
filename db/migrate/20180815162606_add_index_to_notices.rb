class AddIndexToNotices < ActiveRecord::Migration
  def change
    add_index :notices, :created_at
  end
end
