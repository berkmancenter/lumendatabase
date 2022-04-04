class AddRedactionFieldsToEntities < ActiveRecord::Migration[6.1]
  def change
    add_column :entities, :address_line_1_original, :string
    add_column :entities, :address_line_2_original, :string
    add_column :entities, :city_original, :string
    add_column :entities, :state_original, :string
    add_column :entities, :country_code_original, :string
    add_column :entities, :zip_original, :string
    add_column :entities, :url_original, :string
  end
end
