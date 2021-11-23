class DropEmailFromAchivedTokenUrls < ActiveRecord::Migration[6.1]
  def change
    remove_column :archived_token_urls, :email, :string
  end
end
