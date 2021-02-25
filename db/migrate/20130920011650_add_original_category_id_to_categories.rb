class AddOriginalCategoryIdToCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :original_category_id, :integer
  end
end
