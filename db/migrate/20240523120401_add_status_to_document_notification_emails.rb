class AddStatusToDocumentNotificationEmails < ActiveRecord::Migration[7.1]
  def change
    add_column :document_notification_emails, :status, :integer, default: 1
  end
end
