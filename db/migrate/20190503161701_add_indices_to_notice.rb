class AddIndicesToNotice < ActiveRecord::Migration
  def change
    add_index :notices, :updated_at
    add_index :notices, :published
  end
end
