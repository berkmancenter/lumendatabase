class AddNotesToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :notes, :text
  end
end
