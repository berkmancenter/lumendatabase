class RemoveNullFromUrl < ActiveRecord::Migration
  def change
  	change_column :infringing_urls, :url, :string, null: false, limit: 8192
  	change_column :copyrighted_urls, :url, :string, null: false, limit: 8192
  end
end
