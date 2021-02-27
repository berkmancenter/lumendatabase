class UpdateTokenUrlsFields < ActiveRecord::Migration[4.2]
  def change
    change_column :token_urls, :valid_forever, :boolean, default: false
    change_column :token_urls, :notice_id, :integer, null: false
  end
end
