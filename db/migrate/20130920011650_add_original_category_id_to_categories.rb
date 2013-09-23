class AddOriginalCategoryIdToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :original_category_id, :integer
  end
end
