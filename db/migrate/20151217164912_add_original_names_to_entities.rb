class AddOriginalNamesToEntities < ActiveRecord::Migration
  def change
  	add_column :entities, :original_name, :string
  end
end
