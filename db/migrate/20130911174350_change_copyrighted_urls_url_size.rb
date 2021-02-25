class ChangeCopyrightedUrlsUrlSize < ActiveRecord::Migration[4.2]
  def change
    change_column :copyrighted_urls, :url, :string, limit: 8.kilobytes, null: false
  end
end
