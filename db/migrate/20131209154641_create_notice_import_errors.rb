class CreateNoticeImportErrors < ActiveRecord::Migration
  def change
    create_table(:notice_import_errors) do |t|
      t.integer :original_notice_id
      t.string :file_list, limit: 2.kilobytes
      t.string :message, limit: 16.kilobytes
      t.string :stacktrace, limit: 2.kilobytes
      t.string :import_set_name, limit: 1.kilobyte
      t.timestamps
    end
  end
end
