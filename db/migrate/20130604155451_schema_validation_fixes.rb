class SchemaValidationFixes < ActiveRecord::Migration
  def change
    change_column :categories, :name, :string, null: false

    change_column :category_managers, :name, :string, null: false

    change_column :entity_notice_roles, :notice_id, :integer, null: false
    change_column :entity_notice_roles, :entity_id, :integer, null: false
    change_column :entity_notice_roles, :name, :string, null: false

    change_column :notices, :title, :string, null: false

    change_column :relevant_questions, :question, :string, null: false
    change_column :relevant_questions, :answer, :string, null: false
  end
end
