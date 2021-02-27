class AddCopyrightedUrls < ActiveRecord::Migration[4.2]
  def change
    create_table :copyrighted_urls do |t|
      t.string :url, limit: 1.kilobyte, null: false
      t.timestamps
    end
    add_index :copyrighted_urls, :url, unique: true

    create_table(:copyrighted_urls_works, id: false) do |t|
      t.belongs_to :copyrighted_url, null: false
      t.belongs_to :work, null: false
    end

    add_index :copyrighted_urls_works, :copyrighted_url_id
    add_index :copyrighted_urls_works, :work_id
  end
end
