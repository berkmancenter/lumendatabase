class AddPdfRequestFulfilledToFileUploads < ActiveRecord::Migration[4.2]
  def change
    add_column :file_uploads, :pdf_request_fulfilled, :boolean
  end
end
