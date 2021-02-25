class AddKindToWorks < ActiveRecord::Migration[4.2]
  def change
    add_column :works, :kind, :string
  end
end
