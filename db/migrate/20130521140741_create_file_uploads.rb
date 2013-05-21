class CreateFileUploads < ActiveRecord::Migration
  def change
    create_table :file_uploads do |t|
      t.belongs_to :notice
      t.string :kind
    end
    add_attachment :file_uploads, :file
    add_index :file_uploads, :notice_id
  end
end
