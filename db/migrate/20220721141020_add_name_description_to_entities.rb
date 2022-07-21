class AddNameDescriptionToEntities < ActiveRecord::Migration[6.1]
  def change
    add_column :entities, :name_description, :text
  end
end
