# frozen_string_literal: true

require 'rails_helper'

describe Enterprise::PaymentProviders::Stripe::CheckoutSession do
  let(:account) { create(:enterprise_account, :inactive) }
  let(:user) { create(:user, :enterprise, enterprise_account: account) }

  before do
    LumenSetting.where(key: 'enterprise_pro_price_usd').delete_all
    LumenSetting.create!(
      name: 'Enterprise Pro price',
      key: 'enterprise_pro_price_usd',
      value: '499.99'
    )
    allow(Stripe).to receive(:api_key).and_return('sk_test_123')
  end

  it 'creates a pending payment and a Stripe Checkout session using server-side pricing' do
    stripe_session = instance_double(
      Stripe::Checkout::Session,
      id: 'cs_test_123',
      customer: 'cus_test_123',
      url: 'https://checkout.stripe.com/c/pay/cs_test_123'
    )

    expect(Stripe::Checkout::Session).to receive(:create) do |payload, options|
      payment_id = payload[:metadata][:enterprise_payment_id]

      expect(payload[:mode]).to eq('payment')
      expect(payload[:payment_method_types]).to eq(['card'])
      expect(payload[:customer_email]).to eq(user.email)
      expect(payload[:client_reference_id]).to eq(account.id.to_s)
      expect(payload[:line_items].first[:price_data][:unit_amount]).to eq(49_999)
      expect(payload[:line_items].first[:price_data][:currency]).to eq('usd')
      expect(payload[:metadata][:enterprise_account_id]).to eq(account.id.to_s)
      expect(payload[:payment_intent_data][:metadata][:enterprise_payment_id]).to eq(payment_id)
      expect(options[:idempotency_key]).to eq("enterprise-payment-#{payment_id}")

      stripe_session
    end

    result = described_class.new(
      enterprise_account: account,
      user: user,
      success_url: 'https://example.com/enterprise/pay/success?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: 'https://example.com/enterprise/pay/cancel'
    ).create

    payment = result.payment.reload
    expect(result.session).to eq(stripe_session)
    expect(payment).to be_persisted
    expect(payment.status).to eq('pending')
    expect(payment.amount_cents).to eq(49_999)
    expect(payment.stripe_checkout_session_id).to eq('cs_test_123')
    expect(account.reload.payment_method).to eq('credit_card')
    expect(account.plan).to eq('inactive')
  end

  it 'raises a configuration error without a Stripe secret key' do
    allow(Stripe).to receive(:api_key).and_return(nil)

    expect do
      described_class.new(
        enterprise_account: account,
        user: user,
        success_url: 'https://example.com/success',
        cancel_url: 'https://example.com/cancel'
      ).create
    end.to raise_error(Enterprise::PaymentProviders::Stripe::ConfigurationError, /Stripe is not configured/)

    expect(account.enterprise_payments.count).to eq(0)
  end
end
