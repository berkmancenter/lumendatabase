# frozen_string_literal: true

class Lumen::Enterprise::PaymentProviders::Stripe::Cancellation
  def initialize(payment:)
    @payment = payment
  end

  def call
    payment.with_lock do
      return :not_pending unless payment.pending?

      expire_checkout_session!
      payment.update!(status: 'canceled')
    end

    :canceled
  rescue ::Stripe::StripeError => e
    Rails.logger.error("Stripe Checkout cancellation failed: #{e.class}: #{e.message}")
    raise Lumen::Enterprise::PaymentProviders::Stripe::Error,
          'We could not cancel the pending card payment. Please try again.'
  end

  private

  attr_reader :payment

  def expire_checkout_session!
    return if payment.stripe_checkout_session_id.blank?
    return if ::Stripe.api_key.blank?

    ::Stripe::Checkout::Session.expire(payment.stripe_checkout_session_id)
  end
end
