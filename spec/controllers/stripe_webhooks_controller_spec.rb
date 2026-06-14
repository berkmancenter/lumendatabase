require 'rails_helper'

describe StripeWebhooksController do
  let(:payload) { '{"id":"evt_test"}' }
  let(:stripe_event) { instance_double(Stripe::Event) }

  around do |example|
    previous_secret = ENV['STRIPE_WEBHOOK_SECRET']
    ENV['STRIPE_WEBHOOK_SECRET'] = 'whsec_test'
    example.run
  ensure
    ENV['STRIPE_WEBHOOK_SECRET'] = previous_secret
  end

  before do
    request.headers['Stripe-Signature'] = 'signature'
    allow(Lumen::Enterprise::PaymentProviders::Stripe).to receive(:construct_event)
      .with(payload: payload, signature: 'signature')
      .and_return(stripe_event)
    allow(Lumen::Enterprise::PaymentProviders::Stripe).to receive(:handle_webhook)
      .with(stripe_event)
      .and_return(:completed)
  end

  it 'verifies the signature and delegates provider-specific webhook handling' do
    post :create, body: payload

    expect(response).to have_http_status(:ok)
    expect(Lumen::Enterprise::PaymentProviders::Stripe).to have_received(:handle_webhook)
      .with(stripe_event)
  end

  it 'rejects events with invalid signatures' do
    allow(Lumen::Enterprise::PaymentProviders::Stripe).to receive(:construct_event)
      .and_raise(Lumen::Enterprise::PaymentProviders::Stripe::InvalidWebhook, 'bad signature')

    post :create, body: payload

    expect(response).to have_http_status(:bad_request)
    expect(Lumen::Enterprise::PaymentProviders::Stripe).not_to have_received(:handle_webhook)
  end
end
