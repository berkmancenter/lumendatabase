class AddColumnsToBlogEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :blog_entries, :original_news_id, :integer
    add_column :blog_entries, :url, :string, limit: 1.kilobyte
  end
end
