require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

RejectApiSubmitterRequestProc = proc do
  if request.get?
    ApiSubmitterRequest.find(params[:id]).reject_request

    redirect_to rails_admin.index_path(model_name: 'ApiSubmitterRequest')
  end
end

module RailsAdmin
  module Config
    module Actions
      class RejectApiSubmitterRequest < Base
        register_instance_option(:only) { 'ApiSubmitterRequest' }
        register_instance_option(:link_icon) { 'icon-minus' }
        register_instance_option(:action_name) { :reject_api_submitter_request }
        register_instance_option(:member) { true }
        register_instance_option(:http_methods) { %i[get] }
        register_instance_option(:controller) { RejectApiSubmitterRequestProc }
        register_instance_option :visible? do
          bindings &&
            (object = bindings[:object]) &&
            object.class.name == 'ApiSubmitterRequest' &&
            object.approved.nil?
        end
      end

      register RejectApiSubmitterRequest
    end
  end
end
