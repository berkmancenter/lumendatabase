require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

# Admin action that rejects a pre_registration enterprise account: marks it
# rejected and emails the applicant (see EnterpriseAccount#reject_registration!).
# Mirrors the reject_api_submitter_request member action.
RejectEnterpriseAccountProc = proc do
  if request.get?
    enterprise_account = EnterpriseAccount.find(params[:id])

    begin
      enterprise_account.reject_registration!

      flash[:success] = "Registration rejected. #{enterprise_account.name} was notified."

      redirect_to rails_admin.show_path(
        model_name: 'enterprise_account',
        id: enterprise_account.id
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = "Registration could not be rejected. #{e.record.errors.full_messages.to_sentence}."

      redirect_to rails_admin.edit_path(
        model_name: 'enterprise_account',
        id: enterprise_account.id
      )
    end
  end
end

module RailsAdmin
  module Config
    module Actions
      class RejectEnterpriseAccount < Base
        register_instance_option(:only) { 'EnterpriseAccount' }
        register_instance_option(:link_icon) { 'fas fa-minus' }
        register_instance_option(:action_name) { :reject_enterprise_account }
        register_instance_option(:member) { true }
        register_instance_option(:http_methods) { %i[get] }
        register_instance_option(:controller) { RejectEnterpriseAccountProc }
        register_instance_option :visible? do
          bindings &&
            (object = bindings[:object]) &&
            object.class.name == 'EnterpriseAccount' &&
            object.status == 'pre_registration' &&
            object.applicant_email.present?
        end
      end

      register RejectEnterpriseAccount
    end
  end
end
