require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

# Admin action that accepts a pre_registration enterprise account: creates the
# enterprise user and emails them the confirm-email/set-password link (see
# EnterpriseAccount#approve_registration!). Mirrors the accept_invoice and
# approve_api_submitter_request member actions.
AcceptEnterpriseAccountProc = proc do
  if request.get?
    enterprise_account = EnterpriseAccount.find(params[:id])

    enterprise_account.approve_registration!

    flash[:success] = "Registration accepted. #{enterprise_account.name} was emailed " \
                      'a link to confirm their email and set a password.'

    redirect_to rails_admin.show_path(
      model_name: 'enterprise_account',
      id: enterprise_account.id
    )
  end
end

module RailsAdmin
  module Config
    module Actions
      class AcceptEnterpriseAccount < Base
        register_instance_option(:only) { 'EnterpriseAccount' }
        register_instance_option(:link_icon) { 'fas fa-check' }
        register_instance_option(:action_name) { :accept_enterprise_account }
        register_instance_option(:member) { true }
        register_instance_option(:http_methods) { %i[get] }
        register_instance_option(:controller) { AcceptEnterpriseAccountProc }
        register_instance_option :visible? do
          bindings &&
            (object = bindings[:object]) &&
            object.class.name == 'EnterpriseAccount' &&
            object.status == 'pre_registration'
        end
      end

      register AcceptEnterpriseAccount
    end
  end
end
