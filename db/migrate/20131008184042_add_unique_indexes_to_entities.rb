class AddUniqueIndexesToEntities < ActiveRecord::Migration[4.2]
  def change
    add_index :entities, [
      :name, :address_line_1, :city, :state, :zip, :country_code, :phone, :email
    ], unique: true, name: 'unique_entity_attribute_index'
  end
end
