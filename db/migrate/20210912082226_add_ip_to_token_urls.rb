class AddIpToTokenUrls < ActiveRecord::Migration[6.1]
  def change
    add_column :token_urls, :ip, :string
    add_column :archived_token_urls, :ip, :string
  end
end
