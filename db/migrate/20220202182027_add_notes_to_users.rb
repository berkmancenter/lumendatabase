class AddNotesToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :notes, :text
  end
end
