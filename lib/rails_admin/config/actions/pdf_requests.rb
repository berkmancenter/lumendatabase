require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

PdfRequestProc = Proc.new do
  flash[:notice] = "Testing"
  redirect_to back_or_index
end
 
module RailsAdmin
  module Config
    module Actions
      class PdfRequests < Base
        register_instance_option(:only) { 'FileUpload' }
        register_instance_option(:link_icon) { 'icon-adjust' }
        #register_instance_option(:action_name) { :pdf_request }
        register_instance_option(:collection) { true }
        register_instance_option(:http_methods) { %i( get post ) }
        register_instance_option(:controller) { PdfRequestProc }
      end

      register PdfRequests
    end
  end
end