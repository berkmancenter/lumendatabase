class AddCityToEntities < ActiveRecord::Migration[4.2]
  def change
    add_column :entities, :city, :string
    add_column :entities, :zip, :string
  end
end
