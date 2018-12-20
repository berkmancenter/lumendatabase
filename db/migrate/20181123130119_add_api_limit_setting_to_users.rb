class AddApiLimitSettingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :limit_notice_api_response, :boolean
  end
end
