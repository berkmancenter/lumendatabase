class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table(:roles) do |t|
      t.string :name, null: false
    end

    create_table(:roles_users) do |t|
      t.belongs_to :role
      t.belongs_to :user
    end

    add_index(:roles_users, :role_id)
    add_index(:roles_users, :user_id)
  end
end
