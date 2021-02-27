class CreateEntities < ActiveRecord::Migration[4.2]
  def change
    create_table :entities do |t|
      t.string :name, null: false
      t.string :kind, null: false, default: 'individual'
      t.string :address_line_1
      t.string :address_line_2
      t.string :state
      t.string :country_code
      t.string :phone
      t.string :email
      t.string :url
      t.string :ancestry
    end

    add_index :entities, :ancestry
  end
end
