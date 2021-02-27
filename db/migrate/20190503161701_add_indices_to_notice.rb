class AddIndicesToNotice < ActiveRecord::Migration[4.2]
  def change
    add_index :notices, :updated_at
    add_index :notices, :published
  end
end
