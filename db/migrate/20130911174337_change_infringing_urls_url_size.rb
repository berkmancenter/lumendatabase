class ChangeInfringingUrlsUrlSize < ActiveRecord::Migration
  def change
    change_column :infringing_urls, :url, :string, limit: 8.kilobytes, null: false
  end
end
