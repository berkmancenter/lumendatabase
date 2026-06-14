# frozen_string_literal: true

module Lumen::Enterprise::PaymentProviders::Stripe
  class Error < Lumen::Enterprise::PaymentProviders::Error; end
  class ConfigurationError < Error; end
  class InvalidWebhook < Error; end

  def self.create_checkout_session(enterprise_account:, user:, success_url:, cancel_url:)
    CheckoutSession.new(
      enterprise_account: enterprise_account,
      user: user,
      success_url: success_url,
      cancel_url: cancel_url
    ).create
  end

  def self.cancel_payment(payment:)
    Cancellation.new(payment: payment).call
  end

  def self.construct_event(payload:, signature:)
    ::Stripe::Webhook.construct_event(
      payload,
      signature,
      ENV.fetch('STRIPE_WEBHOOK_SECRET')
    )
  rescue JSON::ParserError, ::Stripe::SignatureVerificationError => e
    raise InvalidWebhook, e.message
  rescue KeyError => e
    raise ConfigurationError, e.message
  end

  def self.handle_webhook(event)
    case event_type(event)
    when 'checkout.session.completed'
      Fulfillment.new(event: event).call
    when 'checkout.session.expired'
      Expiration.new(event: event).call
    else
      :ignored
    end
  end

  def self.event_type(event)
    event.respond_to?(:type) ? event.type : event[:type]
  end
  private_class_method :event_type
end
