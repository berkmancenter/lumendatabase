class AddPdfRequestFulfilledToFileUploads < ActiveRecord::Migration
  def change
    add_column :file_uploads, :pdf_request_fulfilled, :boolean
  end
end
