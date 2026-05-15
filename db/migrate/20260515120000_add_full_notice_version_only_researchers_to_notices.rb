class AddFullNoticeVersionOnlyResearchersToNotices < ActiveRecord::Migration[7.2]
  def change
    add_column :notices, :full_notice_version_only_researchers, :boolean, default: false, null: false
  end
end
