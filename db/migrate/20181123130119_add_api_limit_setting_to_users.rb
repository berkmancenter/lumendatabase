class AddApiLimitSettingToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :limit_notice_api_response, :boolean
  end
end
