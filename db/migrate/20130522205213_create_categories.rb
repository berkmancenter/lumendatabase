class CreateCategories < ActiveRecord::Migration[4.2]
  def change
    create_table(:categories) do |t|
      t.string :name
      t.string :description
      t.string :ancestry
    end

    add_index :categories, :ancestry

    create_table(:categories_notices) do |t|
      t.belongs_to :category
      t.belongs_to :notice
    end

    add_index :categories_notices, :category_id
    add_index :categories_notices, :notice_id
  end
end
