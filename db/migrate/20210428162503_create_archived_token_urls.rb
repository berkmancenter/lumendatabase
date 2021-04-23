class CreateArchivedTokenUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :archived_token_urls do |t|
      t.string :email, index: true, null: true
      t.string :token, index: true
      t.references :notice, index: true
      t.references :user, index: true, null: true
      t.datetime :expiration_date, null: true
      t.boolean :valid_forever
      t.boolean :documents_notification, index: true
      t.integer :views, default: 0
      t.timestamps
    end
  end
end
