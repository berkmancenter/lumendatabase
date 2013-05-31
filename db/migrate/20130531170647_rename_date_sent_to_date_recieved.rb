class RenameDateSentToDateRecieved < ActiveRecord::Migration
  def change
    rename_column(:notices, :date_sent, :date_received)
  end
end
