class CreateBlockedTokenUrlDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :blocked_token_url_domains do |t|
      t.string :name, index: true
      t.string :comments, null: true
      t.timestamps
    end
  end
end
