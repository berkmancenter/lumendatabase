class AddDocumentsNotificationsToTokenUrls < ActiveRecord::Migration
  def change
    add_column :token_urls, :documents_notification, :boolean
    add_index :token_urls, :documents_notification
  end
end
