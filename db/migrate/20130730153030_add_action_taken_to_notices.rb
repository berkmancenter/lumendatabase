class AddActionTakenToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :action_taken, :string, null: false, default: 'No')
  end
end
