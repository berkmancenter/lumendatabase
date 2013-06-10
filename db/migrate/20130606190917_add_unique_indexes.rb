class AddUniqueIndexes < ActiveRecord::Migration
  def change
    add_index :infringing_urls, :url, unique: true
    add_index :entities, :name, unique: true
  end
end
