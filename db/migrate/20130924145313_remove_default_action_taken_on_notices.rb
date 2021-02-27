class RemoveDefaultActionTakenOnNotices < ActiveRecord::Migration[4.2]
  def change
    change_column_default(:notices, :action_taken, nil)
  end
end
