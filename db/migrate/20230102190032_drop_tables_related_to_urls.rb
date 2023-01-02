class DropTablesRelatedToUrls < ActiveRecord::Migration[6.1]
  def change
    drop_table :copyrighted_urls, if_exists: true
    drop_table :copyrighted_urls_works, if_exists: true
    drop_table :infringing_urls, if_exists: true
    drop_table :infringing_urls_works, if_exists: true
    drop_table :works, if_exists: true
    drop_table :notices_works, if_exists: true
  end
end
