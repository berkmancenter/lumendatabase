class ChangeCategoriesDescriptionType < ActiveRecord::Migration
  def up
    change_column(:categories, :description, :text)
  end

  def down
    change_column(:categories, :description, :string)
  end
end
