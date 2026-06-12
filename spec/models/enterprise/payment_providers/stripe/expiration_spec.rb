# frozen_string_literal: true

require 'rails_helper'

describe Enterprise::PaymentProviders::Stripe::Expiration do
  ExpirationEventData = Struct.new(:object, keyword_init: true)
  ExpirationEvent = Struct.new(:id, :type, :created, :data, keyword_init: true)
  ExpirationCheckoutSession = Struct.new(:id, :metadata, keyword_init: true)

  let(:payment) do
    create(:enterprise_payment, stripe_checkout_session_id: 'cs_test_expired')
  end
  let(:session) do
    ExpirationCheckoutSession.new(
      id: 'cs_test_expired',
      metadata: { 'enterprise_payment_id' => payment.id.to_s }
    )
  end
  let(:event) do
    ExpirationEvent.new(
      id: 'evt_expired',
      type: 'checkout.session.expired',
      created: Time.current.to_i,
      data: ExpirationEventData.new(object: session)
    )
  end

  it 'marks a pending payment expired' do
    expect(described_class.new(event: event).call).to eq(:expired)
    expect(payment.reload.status).to eq('expired')
  end

  it 'does not change completed payments' do
    payment.update!(status: 'completed', completed_at: Time.current)

    described_class.new(event: event).call

    expect(payment.reload.status).to eq('completed')
  end
end
