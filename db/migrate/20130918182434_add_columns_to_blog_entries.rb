class AddColumnsToBlogEntries < ActiveRecord::Migration
  def change
    add_column :blog_entries, :original_news_id, :integer
    add_column :blog_entries, :url, :string, limit: 1.kilobyte
  end
end
