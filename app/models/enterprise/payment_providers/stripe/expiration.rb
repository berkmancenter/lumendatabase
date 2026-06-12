# frozen_string_literal: true

class Enterprise::PaymentProviders::Stripe::Expiration
  def initialize(event:)
    @event = event
  end

  def call
    return :ignored unless event_type == 'checkout.session.expired'

    payment = find_payment
    return :missing_payment unless payment

    payment.with_lock do
      payment.update!(status: 'expired') if payment.status == 'pending'
    end

    :expired
  end

  private

  attr_reader :event

  def find_payment
    EnterprisePayment.find_by(stripe_checkout_session_id: session_value(:id)) ||
      EnterprisePayment.find_by(id: metadata_value(:enterprise_payment_id))
  end

  def checkout_session
    @checkout_session ||= event.data.object
  end

  def event_type
    event.respond_to?(:type) ? event.type : event[:type]
  end

  def session_value(key)
    value_from(checkout_session, key)
  end

  def metadata_value(key)
    metadata = session_value(:metadata) || {}
    value_from(metadata, key)
  end

  def value_from(object, key)
    return object.public_send(key) if object.respond_to?(key)
    return nil unless object.respond_to?(:[])

    if object.respond_to?(:key?)
      return object[key] if object.key?(key)
      return object[key.to_s] if object.key?(key.to_s)
    end

    object[key]
  rescue KeyError, IndexError, TypeError
    nil
  end
end
