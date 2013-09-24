class RemoveDefaultActionTakenOnNotices < ActiveRecord::Migration
  def change
    change_column_default(:notices, :action_taken, nil)
  end
end
