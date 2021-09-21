class CreateMediaMentions < ActiveRecord::Migration[6.1]
  def change
    create_table :media_mentions do |t|
      t.string :title, limit: 1000
      t.text :description, null: true
      t.string :source, limit: 1000, null: true
      t.string :link_to_source, limit: 1000, null: true
      t.string :scale_of_mention, limit: 1000, null: true
      t.date :date, null: true
      t.string :document_type, limit: 100, null: true
      t.text :comments, null: true
      t.boolean :published, default: false

      t.timestamps
    end
  end
end
