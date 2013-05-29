class CreateRailsAdminHistoriesTable < ActiveRecord::Migration
  def change
    create_table :rails_admin_histories do |t|
      t.text :message # title, name, or object_id
      t.string :username
      t.integer :item
      t.string :table
      t.integer :month, limit: 2
      t.integer :year, limit: 5
      t.timestamps
    end
  end
end
