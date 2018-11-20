class AddTokenUrlsOptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_generate_permanent_notice_token_urls, :boolean
  end
end
