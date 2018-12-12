class AddNoticeViewerSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notice_viewer_views_limit, :integer, default: 1
    add_column :users, :notice_viewer_viewed_notices, :integer, default: 0
    add_column :users, :notice_viewer_time_limit, :datetime
  end
end
