class AddActionTakenToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :action_taken, :string, null: false, default: 'No')
  end
end
