class AddPdfRequestedToFileUploads < ActiveRecord::Migration[4.2]
  def change
    add_column :file_uploads, :pdf_requested, :boolean
  end
end
