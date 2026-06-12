# frozen_string_literal: true

require 'rails_helper'

describe Enterprise::PaymentProviders::Stripe do
  describe '.construct_event' do
    around do |example|
      previous_secret = ENV['STRIPE_WEBHOOK_SECRET']
      ENV['STRIPE_WEBHOOK_SECRET'] = 'whsec_test'
      example.run
    ensure
      ENV['STRIPE_WEBHOOK_SECRET'] = previous_secret
    end

    it 'builds a verified Stripe event from the signed payload' do
      stripe_event = instance_double(Stripe::Event)
      allow(Stripe::Webhook).to receive(:construct_event)
        .with('{"id":"evt_test"}', 'signature', 'whsec_test')
        .and_return(stripe_event)

      expect(described_class.construct_event(payload: '{"id":"evt_test"}', signature: 'signature'))
        .to eq(stripe_event)
    end

    it 'wraps invalid webhooks in a provider error' do
      allow(Stripe::Webhook).to receive(:construct_event)
        .and_raise(Stripe::SignatureVerificationError.new('bad signature', 'signature'))

      expect do
        described_class.construct_event(payload: '{"id":"evt_test"}', signature: 'signature')
      end.to raise_error(described_class::InvalidWebhook, /bad signature/)
    end
  end

  describe '.handle_webhook' do
    let(:stripe_event) { instance_double(Stripe::Event, type: event_type) }
    let(:event_type) { 'checkout.session.completed' }

    it 'fulfills completed checkout sessions' do
      fulfillment = instance_double(described_class::Fulfillment, call: :completed)
      allow(described_class::Fulfillment).to receive(:new)
        .with(event: stripe_event)
        .and_return(fulfillment)

      expect(described_class.handle_webhook(stripe_event)).to eq(:completed)
      expect(fulfillment).to have_received(:call)
    end

    context 'with an expired checkout session' do
      let(:event_type) { 'checkout.session.expired' }

      it 'marks the pending payment expired' do
        expiration = instance_double(described_class::Expiration, call: :expired)
        allow(described_class::Expiration).to receive(:new)
          .with(event: stripe_event)
          .and_return(expiration)

        expect(described_class.handle_webhook(stripe_event)).to eq(:expired)
        expect(expiration).to have_received(:call)
      end
    end

    context 'with an unsupported event' do
      let(:event_type) { 'customer.created' }

      it 'ignores the event' do
        expect(described_class.handle_webhook(stripe_event)).to eq(:ignored)
      end
    end
  end
end
