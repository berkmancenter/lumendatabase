class RemoveUniqueNameConstraintFromEntities < ActiveRecord::Migration[6.1]
  def change
    remove_index :entities, ['name', 'address_line_1', 'city', 'state', 'zip', 'country_code', 'phone', 'email']
  end
end
