# frozen_string_literal: true

require 'rails_helper'

describe Enterprise::PaymentProviders::Stripe::Fulfillment do
  FulfillmentEventData = Struct.new(:object, keyword_init: true)
  FulfillmentEvent = Struct.new(:id, :type, :created, :data, keyword_init: true)
  FulfillmentCheckoutSession = Struct.new(
    :id,
    :payment_status,
    :amount_total,
    :currency,
    :payment_intent,
    :customer,
    :metadata,
    keyword_init: true
  )

  let(:completed_at) { Time.utc(2026, 6, 12, 12, 0, 0) }
  let(:account) { create(:enterprise_account, :inactive) }
  let(:user) { create(:user, :enterprise, enterprise_account: account) }
  let(:payment) do
    create(
      :enterprise_payment,
      enterprise_account: account,
      user: user,
      stripe_checkout_session_id: 'cs_test_123'
    )
  end
  let(:session) do
    FulfillmentCheckoutSession.new(
      id: 'cs_test_123',
      payment_status: 'paid',
      amount_total: 50_000,
      currency: 'usd',
      payment_intent: 'pi_test_123',
      customer: 'cus_test_123',
      metadata: {
        'enterprise_account_id' => account.id.to_s,
        'enterprise_payment_id' => payment.id.to_s,
        'user_id' => user.id.to_s
      }
    )
  end
  let(:event) do
    FulfillmentEvent.new(
      id: 'evt_test_123',
      type: 'checkout.session.completed',
      created: completed_at.to_i,
      data: FulfillmentEventData.new(object: session)
    )
  end

  before do
    allow(Enterprise::RegistrationMailer).to receive(:admin_payment)
      .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
    allow(Enterprise::RegistrationMailer).to receive(:client_confirmation)
      .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
  end

  it 'activates Pro, records the Stripe identifiers, and sends notifications' do
    expect(described_class.new(event: event).call).to eq(:completed)

    account.reload
    payment.reload

    expect(account.plan).to eq('pro')
    expect(account.payment_method).to eq('credit_card')
    expect(account.paid_until).to be_within(1.minute).of(completed_at + 1.month)
    expect(payment.status).to eq('completed')
    expect(payment.stripe_payment_intent_id).to eq('pi_test_123')
    expect(payment.stripe_customer_id).to eq('cus_test_123')
    expect(payment.stripe_event_id).to eq('evt_test_123')
    expect(payment.completed_at).to eq(completed_at)
    expect(payment.period_started_at).to eq(completed_at)
    expect(payment.period_ends_at).to eq(account.paid_until)
    expect(Enterprise::RegistrationMailer).to have_received(:admin_payment).with(account, user)
    expect(Enterprise::RegistrationMailer).to have_received(:client_confirmation).with(account, user)
  end

  it 'does not extend access twice when Stripe retries the same session' do
    described_class.new(event: event).call
    paid_until = account.reload.paid_until

    expect(described_class.new(event: event).call).to eq(:already_completed)

    expect(account.reload.paid_until).to eq(paid_until)
    expect(Enterprise::RegistrationMailer).to have_received(:admin_payment).once
    expect(Enterprise::RegistrationMailer).to have_received(:client_confirmation).once
  end

  it 'extends from an existing future paid period' do
    future_paid_until = Time.utc(2026, 7, 12, 12, 0, 0)
    account.update!(plan: 'pro', paid_until: future_paid_until)

    described_class.new(event: event).call

    expect(account.reload.paid_until).to eq(future_paid_until + 1.month)
    expect(payment.reload.period_started_at).to eq(future_paid_until)
  end

  it 'ignores unpaid completed sessions' do
    session.payment_status = 'unpaid'

    expect(described_class.new(event: event).call).to eq(:ignored)
    expect(account.reload.plan).to eq('inactive')
    expect(payment.reload.status).to eq('pending')
  end

  it 'does not fulfill a canceled local payment' do
    payment.update!(status: 'canceled')

    expect(described_class.new(event: event).call).to eq(:not_pending)
    expect(account.reload.plan).to eq('inactive')
  end

  it 'returns missing_payment when the session cannot be reconciled' do
    payment.destroy!

    expect(described_class.new(event: event).call).to eq(:missing_payment)
    expect(account.reload.plan).to eq('inactive')
  end
end
