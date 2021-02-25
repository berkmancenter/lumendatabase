class ModifyActionTakenOnNotice < ActiveRecord::Migration[4.2]
  def change
    change_column :notices, :action_taken, :string, default: "No", null: true
  end
end
