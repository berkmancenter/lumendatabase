class AddWidgetAuthTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :widget_public_key, :string
    add_index :users, :widget_public_key, unique: true
  end
end
