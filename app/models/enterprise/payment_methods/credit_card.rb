# frozen_string_literal: true

class Enterprise::PaymentMethods::CreditCard < Enterprise::PaymentMethods::Base
  PAYMENT_METHOD = 'credit_card'

  def initialize(provider: Enterprise::PaymentProviders.fetch('stripe'), **context)
    super(**context)
    @provider = provider
  end

  def start
    if pending_payment
      return redirect_result(
        redirect_to: urls.fetch(:status_path),
        alert: 'You already have a card payment in progress. Cancel it before starting another.'
      )
    end

    result = provider.create_checkout_session(
      enterprise_account: enterprise_account,
      user: user,
      success_url: urls.fetch(:success_url),
      cancel_url: urls.fetch(:cancel_url)
    )

    redirect_result(
      redirect_to: result.session.url,
      allow_other_host: true,
      status: :see_other
    )
  rescue Enterprise::PaymentProviders::Error => e
    Rails.logger.error("Could not start Enterprise credit-card payment: #{e.message}")
    redirect_result(redirect_to: urls.fetch(:settings_path), alert: e.message)
  end

  def cancel(payment:)
    provider.cancel_payment(payment: payment)
  rescue Enterprise::PaymentProviders::Error => e
    raise Enterprise::PaymentMethods::Error, e.message
  end

  private

  attr_reader :provider
end
