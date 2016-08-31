class AddOriginalNamesToEntities < ActiveRecord::Migration
  def change
  	add_column :entities, :name_original, :string
  end
end
