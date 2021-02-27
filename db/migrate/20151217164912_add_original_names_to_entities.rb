class AddOriginalNamesToEntities < ActiveRecord::Migration[4.2]
  def change
  	add_column :entities, :name_original, :string
  end
end
