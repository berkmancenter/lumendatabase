class CreateFileUploads < ActiveRecord::Migration[4.2]
  def change
    create_table :file_uploads do |t|
      t.belongs_to :notice
      t.string :kind
    end

    add_column :file_uploads, :file_file_name, :string
    add_column :file_uploads, :file_file_size, :integer
    add_column :file_uploads, :file_content_type, :string
    add_column :file_uploads, :file_updated_at, :datetime

    add_index :file_uploads, :notice_id
  end
end
