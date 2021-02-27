class AddUserIdToEntities < ActiveRecord::Migration[4.2]
  def change
    add_column(:entities, :user_id, :integer)
    add_index(:entities, :user_id)
  end
end
