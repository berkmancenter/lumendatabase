require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

PdfRequestProc = Proc.new do
  @requested_pdfs = FileUpload.where pdf_requested: true, pdf_request_fulfilled: false
  render @action.template_name
end
 
module RailsAdmin
  module Config
    module Actions
      class PdfRequests < Base
        register_instance_option(:only) { 'FileUpload' }
        register_instance_option(:link_icon) { 'icon-adjust' }
        register_instance_option(:collection) { true }
        register_instance_option(:http_methods) { %i( get post ) }
        register_instance_option(:controller) { PdfRequestProc }
      end

      register PdfRequests
    end
  end
end

