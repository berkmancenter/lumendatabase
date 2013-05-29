class CreateEntityNoticeRoles < ActiveRecord::Migration
  def change
    create_table :entity_notice_roles do |t|
      t.belongs_to :entity
      t.belongs_to :notice
      t.string :name
      t.timestamps
    end

    add_index :entity_notice_roles, :entity_id
    add_index :entity_notice_roles, :notice_id
  end
end
