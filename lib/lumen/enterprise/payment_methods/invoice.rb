# frozen_string_literal: true

class Lumen::Enterprise::PaymentMethods::Invoice < Lumen::Enterprise::PaymentMethods::Base
  PAYMENT_METHOD = 'invoice'

  def start
    if enterprise_account.pending_payment.present?
      return redirect_result(
        redirect_to: urls.fetch(:status_path),
        alert: 'Cancel your pending card payment before choosing another payment method.'
      )
    end

    enterprise_account.update!(payment_method: payment_method)
    Enterprise::RegistrationMailer.admin_payment(enterprise_account, user).deliver_later

    redirect_result(
      redirect_to: urls.fetch(:settings_path),
      notice: 'Thanks - we will follow up with you about invoicing. ' \
              'Your Pro access unlocks once the invoice has been paid.'
    )
  end

  def cancel(payment:)
    raise Lumen::Enterprise::PaymentMethods::Error,
          "Pending #{payment.payment_method} payments cannot be canceled from this screen."
  end
end
