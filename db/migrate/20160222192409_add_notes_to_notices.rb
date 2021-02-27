class AddNotesToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :notes, :text
  end
end
