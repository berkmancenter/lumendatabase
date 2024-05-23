class AddStatusToDocumentsUpdateNotificationNotices < ActiveRecord::Migration[7.1]
  def change
    add_column :documents_update_notification_notices, :status, :integer, default: 0
  end
end
