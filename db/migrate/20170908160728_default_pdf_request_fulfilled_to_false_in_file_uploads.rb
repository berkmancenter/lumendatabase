class DefaultPdfRequestFulfilledToFalseInFileUploads < ActiveRecord::Migration[4.2]
  def change
    change_column_default :file_uploads, :pdf_request_fulfilled, false
  end
end
