class AddDateSentToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :date_sent, :datetime)
  end
end
