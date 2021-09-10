class CreateBlockedTokenUrlsIps < ActiveRecord::Migration[6.1]
  def change
    create_table :blocked_token_url_ips do |t|
      t.string :address, index: true
      t.string :comments, null: true
      t.timestamps
    end
  end
end
