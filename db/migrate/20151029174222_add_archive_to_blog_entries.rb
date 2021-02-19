class AddArchiveToBlogEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :blog_entries, :archive, :boolean, default: false
  end
end
