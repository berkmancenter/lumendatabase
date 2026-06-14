# frozen_string_literal: true

require 'rails_helper'

describe Lumen::Enterprise::PaymentMethods::CreditCard do
  let(:account) { create(:enterprise_account, :inactive) }
  let(:user) { create(:user, :enterprise, enterprise_account: account) }
  let(:urls) do
    {
      success_url: 'https://example.com/success',
      cancel_url: 'https://example.com/cancel',
      settings_path: '/enterprise/settings',
      status_path: '/enterprise/status'
    }
  end
  let(:provider) { class_double(Lumen::Enterprise::PaymentProviders::Stripe) }

  subject(:payment_method) do
    described_class.new(
      enterprise_account: account,
      user: user,
      urls: urls,
      provider: provider
    )
  end

  it 'starts checkout through the configured provider' do
    checkout_result = Lumen::Enterprise::PaymentProviders::Stripe::CheckoutSession::Result.new(
      payment: instance_double(EnterprisePayment),
      session: instance_double(Stripe::Checkout::Session, url: 'https://checkout.example/session')
    )
    allow(provider).to receive(:create_checkout_session).and_return(checkout_result)

    result = payment_method.start

    expect(provider).to have_received(:create_checkout_session).with(
      enterprise_account: account,
      user: user,
      success_url: urls[:success_url],
      cancel_url: urls[:cancel_url]
    )
    expect(result.redirect_to).to eq('https://checkout.example/session')
    expect(result.allow_other_host).to eq(true)
    expect(result.status).to eq(:see_other)
  end

  it 'blocks duplicate pending payments before calling the provider' do
    create(:enterprise_payment, enterprise_account: account, user: user)
    allow(provider).to receive(:create_checkout_session)

    result = payment_method.start

    expect(provider).not_to have_received(:create_checkout_session)
    expect(result.redirect_to).to eq('/enterprise/status')
    expect(result.alert).to match(/already have a card payment/)
  end

  it 'cancels through the configured provider' do
    payment = create(:enterprise_payment, enterprise_account: account, user: user)
    allow(provider).to receive(:cancel_payment).with(payment: payment).and_return(:canceled)

    expect(payment_method.cancel(payment: payment)).to eq(:canceled)
  end
end
