class AddArchiveToBlogEntries < ActiveRecord::Migration
  def change
    add_column :blog_entries, :archive, :boolean, default: false
  end
end
