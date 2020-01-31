class RemoveBlogEntries < ActiveRecord::Migration[5.2]
  def change
    drop_table :blog_entries do |t|
      t.belongs_to :user

      t.string :author, null: false
      t.string :title, null: false
      t.string :image
      t.string :url, limit: 1.kilobyte

      t.text :abstract
      t.text :content

      t.integer :original_news_id

      t.datetime :published_at

      t.boolean :archive, default: false

      t.timestamps
    end
  end
end
