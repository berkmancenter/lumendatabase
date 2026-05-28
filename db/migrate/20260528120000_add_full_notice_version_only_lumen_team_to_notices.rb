class AddFullNoticeVersionOnlyLumenTeamToNotices < ActiveRecord::Migration[7.0]
  def change
    add_column :notices, :full_notice_version_only_lumen_team, :boolean, default: false, null: false
  end
end
