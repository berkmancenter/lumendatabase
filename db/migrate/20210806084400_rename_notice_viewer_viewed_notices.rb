class RenameNoticeViewerViewedNotices < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :notice_viewer_viewed_notices, :viewed_notices
  end
end
