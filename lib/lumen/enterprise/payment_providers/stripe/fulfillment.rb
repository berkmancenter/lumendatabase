# frozen_string_literal: true

class Lumen::Enterprise::PaymentProviders::Stripe::Fulfillment
  def initialize(event:)
    @event = event
  end

  def call
    return :ignored unless event_type == 'checkout.session.completed'
    return :ignored unless payment_status == 'paid'

    payment = find_payment
    return :missing_payment unless payment
    return :already_completed if payment.completed?
    return :not_pending unless payment.pending?

    fulfilled = fulfill_payment!(payment)
    notify_payment_complete(payment) if fulfilled

    return :not_pending unless fulfilled

    :completed
  end

  private

  attr_reader :event

  def fulfill_payment!(payment)
    fulfilled = false

    payment.with_lock do
      if payment.pending?
        account = payment.enterprise_account
        account.lock!

        completed_at = event_time
        period_started_at = [account.paid_until, completed_at].compact.max

        account.payment_method = 'credit_card'
        account.extend_pro_access!(from: completed_at)

        payment.assign_attributes(
          status: 'completed',
          amount_cents: session_value(:amount_total) || payment.amount_cents,
          currency: session_value(:currency).presence || payment.currency,
          stripe_checkout_session_id: session_value(:id),
          stripe_payment_intent_id: session_value(:payment_intent),
          stripe_customer_id: session_value(:customer),
          stripe_event_id: event_id,
          period_started_at: period_started_at,
          period_ends_at: account.paid_until,
          completed_at: completed_at
        )

        account.save!
        payment.save!
        fulfilled = true
      end
    end

    fulfilled
  end

  def notify_payment_complete(payment)
    account = payment.enterprise_account
    user = payment.user || account.users.order(:id).first
    return unless user

    Enterprise::RegistrationMailer.admin_payment(account, user).deliver_later
    Enterprise::RegistrationMailer.client_confirmation(account, user).deliver_later
  end

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

  def event_id
    event.respond_to?(:id) ? event.id : event[:id]
  end

  def event_time
    created = event.respond_to?(:created) ? event.created : event[:created]
    created.present? ? Time.zone.at(created) : Time.current
  end

  def payment_status
    session_value(:payment_status)
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
