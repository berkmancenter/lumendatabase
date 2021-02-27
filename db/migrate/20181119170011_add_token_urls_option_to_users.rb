class AddTokenUrlsOptionToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :can_generate_permanent_notice_token_urls, :boolean
  end
end
