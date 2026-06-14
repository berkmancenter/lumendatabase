# Lets a confirmed enterprise user choose and pay for a Pro plan from settings.
class Enterprise::PaymentsController < Enterprise::ConfirmedBaseController
  def create
    result = payment_method_strategy(params[:payment_method]).start

    redirect_from(result)
  rescue Lumen::Enterprise::PaymentMethods::UnsupportedPaymentMethod => e
    redirect_to enterprise_settings_path, alert: e.message
  end

  def success
    if enterprise_account.pro?
      redirect_to enterprise_my_notices_path,
                  notice: 'Payment received. Your Pro access is ready.'
    else
      redirect_to enterprise_status_path,
                  notice: 'Thanks - Stripe is confirming your card payment. ' \
                          'Your Pro access will unlock automatically.'
    end
  end

  def cancel
    payment = enterprise_account.pending_payment

    cancel_payment(payment) if payment

    redirect_to enterprise_settings_path,
                notice: 'Your pending payment was canceled. You can try again whenever you are ready.'
  rescue Lumen::Enterprise::PaymentMethods::Error => e
    redirect_to enterprise_status_path, alert: e.message
  end

  def cancel_pending
    payment = enterprise_account.pending_payment

    if payment.blank?
      return redirect_to enterprise_status_path,
                         alert: 'There is no pending payment to cancel.'
    end

    cancel_payment(payment)

    redirect_to enterprise_settings_path,
                notice: 'Your pending card payment was canceled. You can start a new payment now.'
  rescue Lumen::Enterprise::PaymentMethods::Error => e
    redirect_to enterprise_status_path, alert: e.message
  end

  private

  def payment_method_strategy(payment_method)
    Lumen::Enterprise::PaymentMethods.for(
      payment_method,
      enterprise_account: enterprise_account,
      user: current_user,
      urls: payment_urls
    )
  end

  def payment_method_for(payment)
    Lumen::Enterprise::PaymentMethods.for_payment(
      payment,
      enterprise_account: enterprise_account,
      user: current_user,
      urls: payment_urls
    )
  end

  def cancel_payment(payment)
    payment_method_for(payment).cancel(payment: payment)
  end

  def redirect_from(result)
    redirect_to result.redirect_to, result.redirect_options
  end

  def payment_urls
    {
      success_url: "#{enterprise_payment_success_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: enterprise_payment_cancel_url,
      settings_path: enterprise_settings_path,
      status_path: enterprise_status_path
    }
  end
end
