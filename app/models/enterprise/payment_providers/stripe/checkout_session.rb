# frozen_string_literal: true

require 'bigdecimal'

class Enterprise::PaymentProviders::Stripe::CheckoutSession
  PRODUCT_NAME = 'Lumen Enterprise Pro'
  PRODUCT_DESCRIPTION = 'One month of Lumen Enterprise Pro access'
  CURRENCY = 'usd'

  Result = Struct.new(:payment, :session, keyword_init: true)

  def initialize(enterprise_account:, user:, success_url:, cancel_url:)
    @enterprise_account = enterprise_account
    @user = user
    @success_url = success_url
    @cancel_url = cancel_url
  end

  def create
    ensure_configured!

    payment = create_pending_payment!
    session = create_checkout_session!(payment)

    ActiveRecord::Base.transaction do
      enterprise_account.update!(payment_method: 'credit_card')
      payment.update!(
        stripe_checkout_session_id: session.id,
        stripe_customer_id: session.customer
      )
    end

    Result.new(payment: payment, session: session)
  rescue ::Stripe::StripeError => e
    payment&.update(status: 'failed')
    Rails.logger.error("Stripe Checkout session creation failed: #{e.class}: #{e.message}")

    raise Enterprise::PaymentProviders::Stripe::Error,
          'We could not start Stripe Checkout. Please try again.'
  end

  private

  attr_reader :enterprise_account, :user, :success_url, :cancel_url

  def ensure_configured!
    if ::Stripe.api_key.blank?
      raise Enterprise::PaymentProviders::Stripe::ConfigurationError,
            'Stripe is not configured.'
    end

    if amount_cents.blank?
      raise Enterprise::PaymentProviders::Stripe::ConfigurationError,
            'Enterprise Pro pricing is not configured.'
    end
  end

  def create_pending_payment!
    enterprise_account.enterprise_payments.create!(
      user: user,
      amount_cents: amount_cents,
      currency: CURRENCY,
      status: 'pending'
    )
  end

  def create_checkout_session!(payment)
    ::Stripe::Checkout::Session.create(
      checkout_payload(payment),
      idempotency_key: "enterprise-payment-#{payment.id}"
    )
  end

  def checkout_payload(payment)
    metadata = {
      enterprise_account_id: enterprise_account.id.to_s,
      enterprise_payment_id: payment.id.to_s,
      user_id: user.id.to_s
    }

    {
      mode: 'payment',
      payment_method_types: ['card'],
      customer_creation: 'always',
      customer_email: user.email,
      client_reference_id: enterprise_account.id.to_s,
      success_url: success_url,
      cancel_url: cancel_url,
      submit_type: 'pay',
      billing_address_collection: 'auto',
      line_items: [
        {
          price_data: {
            currency: CURRENCY,
            product_data: {
              name: PRODUCT_NAME,
              description: PRODUCT_DESCRIPTION
            },
            unit_amount: amount_cents
          },
          quantity: 1
        }
      ],
      metadata: metadata,
      payment_intent_data: {
        metadata: metadata
      }
    }
  end

  def amount_cents
    @amount_cents ||= begin
      amount = BigDecimal(LumenSetting.get('enterprise_pro_price_usd', cache: false).to_s)
      cents = (amount * 100).round(0).to_i

      cents.positive? ? cents : nil
    rescue ArgumentError
      nil
    end
  end
end
