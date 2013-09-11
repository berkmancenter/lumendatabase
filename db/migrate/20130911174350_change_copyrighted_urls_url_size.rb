class ChangeCopyrightedUrlsUrlSize < ActiveRecord::Migration
  def change
    change_column :copyrighted_urls, :url, :string, limit: 8.kilobytes, null: false
  end
end
