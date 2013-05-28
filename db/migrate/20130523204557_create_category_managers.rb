class CreateCategoryManagers < ActiveRecord::Migration
  def change
    create_table(:category_managers) do |t|
      t.string :name
    end

    create_table(:categories_category_managers) do |t|
      t.belongs_to :category
      t.belongs_to :category_manager
    end

    add_index(:categories_category_managers, :category_id)
    add_index(:categories_category_managers, :category_manager_id)
  end
end
