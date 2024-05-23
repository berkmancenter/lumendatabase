class CreateDocumentNotificationEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :document_notification_emails do |t|
      t.references :notice, null: false
      t.string :email_address, null: false
      t.string :token, null: false

      t.timestamps
    end
  end
end
