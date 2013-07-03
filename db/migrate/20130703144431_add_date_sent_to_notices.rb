class AddDateSentToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :date_sent, :datetime)
  end
end
