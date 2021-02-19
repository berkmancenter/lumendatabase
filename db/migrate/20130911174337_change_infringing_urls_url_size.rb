class ChangeInfringingUrlsUrlSize < ActiveRecord::Migration[4.2]
  def change
    change_column :infringing_urls, :url, :string, limit: 8.kilobytes, null: false
  end
end
