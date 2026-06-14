# frozen_string_literal: true

require 'rails_helper'

describe Lumen::Enterprise::PaymentProviders::Stripe::Cancellation do
  let(:payment) do
    create(:enterprise_payment, stripe_checkout_session_id: 'cs_test_cancel')
  end

  before do
    allow(Stripe).to receive(:api_key).and_return('sk_test_123')
  end

  it 'expires the Stripe Checkout session and marks the payment canceled' do
    expect(Stripe::Checkout::Session).to receive(:expire).with('cs_test_cancel')

    expect(described_class.new(payment: payment).call).to eq(:canceled)
    expect(payment.reload.status).to eq('canceled')
  end

  it 'does not cancel completed payments' do
    payment.update!(status: 'completed', completed_at: Time.current)

    expect(Stripe::Checkout::Session).not_to receive(:expire)
    expect(described_class.new(payment: payment).call).to eq(:not_pending)
    expect(payment.reload.status).to eq('completed')
  end
end
