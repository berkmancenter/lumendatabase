require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

# Admin action for invoice-based enterprise accounts: marks the account Pro,
# extends its paid period by one month, and emails the client that their access
# is ready. Mirrors the approve/reject api-submitter member actions.
AcceptInvoiceProc = proc do
  if request.get?
    enterprise_account = EnterpriseAccount.find(params[:id])

    enterprise_account.extend_pro_access!
    enterprise_account.save!

    recipient = enterprise_account.users.order(:id).first
    if recipient
      Enterprise::RegistrationMailer
        .invoice_accepted(enterprise_account, recipient)
        .deliver_later
    end

    flash[:success] = "Invoice accepted. #{enterprise_account.name} is now Pro " \
                      "until #{enterprise_account.paid_until.to_fs(:simple)}."

    redirect_to rails_admin.show_path(
      model_name: 'enterprise_account',
      id: enterprise_account.id
    )
  end
end

module RailsAdmin
  module Config
    module Actions
      class AcceptInvoice < Base
        register_instance_option(:only) { 'EnterpriseAccount' }
        register_instance_option(:link_icon) { 'fas fa-file-invoice-dollar' }
        register_instance_option(:action_name) { :accept_invoice }
        register_instance_option(:member) { true }
        register_instance_option(:http_methods) { %i[get] }
        register_instance_option(:controller) { AcceptInvoiceProc }
        register_instance_option :visible? do
          bindings &&
            (object = bindings[:object]) &&
            object.class.name == 'EnterpriseAccount' &&
            object.payment_method == 'invoice'
        end
      end

      register AcceptInvoice
    end
  end
end
