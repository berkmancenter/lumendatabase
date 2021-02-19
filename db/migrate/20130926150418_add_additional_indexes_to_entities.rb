class AddAdditionalIndexesToEntities < ActiveRecord::Migration[4.2]
  def change
    remove_index :entities, :name

    %i(name address_line_1 city state zip country_code phone email).each do |column|
      add_index :entities, column
    end
  end
end
