class ModifyActionTakenOnNotice < ActiveRecord::Migration
  def change
    change_column :notices, :action_taken, :string, default: "No", null: true
  end
end
