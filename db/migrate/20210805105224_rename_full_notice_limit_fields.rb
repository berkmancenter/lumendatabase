class RenameFullNoticeLimitFields < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :notice_viewer_views_limit, :full_notice_views_limit
    rename_column :users, :notice_viewer_time_limit, :full_notice_time_limit
  end
end
