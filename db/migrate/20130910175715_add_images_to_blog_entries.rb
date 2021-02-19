class AddImagesToBlogEntries < ActiveRecord::Migration[4.2]
  def change
    add_column(:blog_entries, :image, :string)
  end
end
