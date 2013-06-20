class CreateBlogEntryCategorizations < ActiveRecord::Migration
  def change
    create_table(:blog_entry_categorizations) do |t|
      t.belongs_to :blog_entry
      t.belongs_to :category
    end

    add_index(:blog_entry_categorizations, :blog_entry_id)
    add_index(:blog_entry_categorizations, :category_id)
  end
end
