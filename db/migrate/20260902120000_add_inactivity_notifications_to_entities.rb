class AddInactivityNotificationsToEntities < ActiveRecord::Migration[7.2]
  def change
    add_column :entities, :inactivity_notification_emails, :text
    add_column :entities, :inactivity_notification_after_hours, :integer
    add_column :entities, :inactivity_notification_sent_at, :datetime
  end
end
