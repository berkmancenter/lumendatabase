class CreateInfringingUrls < ActiveRecord::Migration[4.2]
  def change
    create_table(:infringing_urls) do |t|
      t.string :url, limit: 1.kilobyte, null: false
      t.timestamps
    end

    create_table(:infringing_urls_works, id: false) do |t|
      t.belongs_to :infringing_url, null: false
      t.belongs_to :work, null: false
    end

    add_index :infringing_urls_works, :infringing_url_id
    add_index :infringing_urls_works, :work_id
  end
end
