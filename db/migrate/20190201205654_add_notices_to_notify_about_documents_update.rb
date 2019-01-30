class AddNoticesToNotifyAboutDocumentsUpdate < ActiveRecord::Migration
  def change
    create_table :documents_update_notification_notices do |t|
      t.references :notice, null: false
      t.timestamps
    end
  end
end
