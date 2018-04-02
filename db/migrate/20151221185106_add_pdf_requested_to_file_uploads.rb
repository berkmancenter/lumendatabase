class AddPdfRequestedToFileUploads < ActiveRecord::Migration
  def change
    add_column :file_uploads, :pdf_requested, :boolean
  end
end
