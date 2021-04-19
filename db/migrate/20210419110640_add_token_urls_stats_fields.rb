class AddTokenUrlsStatsFields < ActiveRecord::Migration[5.2]
  def change
    add_column :token_urls, :views, :integer, default: 0
    add_column :notices, :views_overall, :integer, default: 0
    add_column :notices, :views_by_notice_viewer, :integer, default: 0
  end
end
