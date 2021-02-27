class RenameDateSentToDateRecieved < ActiveRecord::Migration[4.2]
  def change
    rename_column(:notices, :date_sent, :date_received)
  end
end
