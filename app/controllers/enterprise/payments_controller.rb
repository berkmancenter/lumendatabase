# Lets a confirmed enterprise user choose and "pay for" a Pro plan from settings.
# There is no payment gateway: a credit-card choice activates Pro immediately,
# while an invoice choice waits for an admin to accept the invoice. Admins are
# notified of the payment either way.
class Enterprise::PaymentsController < Enterprise::ConfirmedBaseController
  def create
    case params[:payment_method]
    when 'credit_card'
      activate_with_credit_card
    when 'invoice'
      request_invoice
    else
      redirect_to enterprise_settings_path, alert: 'Please choose a payment method.'
    end
  end

  private

  def activate_with_credit_card
    enterprise_account.payment_method = 'credit_card'
    enterprise_account.extend_pro_access!
    enterprise_account.save!

    notify_admins
    Enterprise::RegistrationMailer
      .client_confirmation(enterprise_account, current_user)
      .deliver_later

    redirect_to enterprise_my_notices_path,
                notice: 'Payment received. Your Pro access is ready.'
  end

  def request_invoice
    enterprise_account.update!(payment_method: 'invoice')

    notify_admins

    redirect_to enterprise_settings_path,
                notice: 'Thanks - we will follow up with you about invoicing. ' \
                        'Your Pro access unlocks once the invoice has been paid.'
  end

  def notify_admins
    Enterprise::RegistrationMailer
      .admin_payment(enterprise_account, current_user)
      .deliver_later
  end
end
