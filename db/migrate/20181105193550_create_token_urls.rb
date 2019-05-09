class CreateTokenUrls < ActiveRecord::Migration
  def change
    create_table :token_urls do |t|
      t.string :email, index: true, null: true
      t.string :token, index: true
      t.references :notice, index: true
      t.references :user, index: true, null: true
      t.datetime :expiration_date, null: true
      t.boolean :valid_forever
      t.timestamps
    end
  end
end
