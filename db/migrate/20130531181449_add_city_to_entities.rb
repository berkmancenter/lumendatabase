class AddCityToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :city, :string
    add_column :entities, :zip, :string
  end
end
