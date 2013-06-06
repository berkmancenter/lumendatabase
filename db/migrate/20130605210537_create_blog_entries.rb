class CreateBlogEntries < ActiveRecord::Migration
  def change
    create_table(:blog_entries) do |t|
      t.belongs_to :user

      t.string :author, null: false
      t.string :title, null: false

      t.text :abstract
      t.text :content

      t.datetime :published_at

      t.timestamps
    end
  end
end
