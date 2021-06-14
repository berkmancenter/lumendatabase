class AddYoutubeImportErrors < ActiveRecord::Migration[5.2]
  def change
    create_table :youtube_import_errors do |t|
      t.integer 'original_notice_id'
      t.text 'message'
      t.string 'filename', limit: 1024
      t.text 'stacktrace'
      t.timestamps
    end
  end
end
