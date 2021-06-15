class CreateYoutubeImportFileLocation < ActiveRecord::Migration[6.0]
  def change
    create_table :youtube_import_file_locations do |t|
      t.references :file_upload, index: true
      t.string :path, null: false
      t.timestamps
    end
  end
end
