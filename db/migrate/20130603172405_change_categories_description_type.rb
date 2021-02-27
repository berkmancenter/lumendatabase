class ChangeCategoriesDescriptionType < ActiveRecord::Migration[4.2]
  def up
    change_column(:categories, :description, :text)
  end

  def down
    change_column(:categories, :description, :string)
  end
end
