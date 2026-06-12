require 'rails_helper'

describe Enterprise::PaymentsController do
  let(:account) { create(:enterprise_account, :inactive) }
  let(:user) { create(:user, :enterprise, enterprise_account: account) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(Enterprise::RegistrationMailer).to receive(:admin_payment)
      .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
  end

  describe '#create' do
    context 'paying by credit card' do
      let(:stripe_session) do
        instance_double(Stripe::Checkout::Session, url: 'https://checkout.stripe.com/c/pay/cs_test')
      end
      let(:checkout_result) do
        Enterprise::PaymentProviders::Stripe::CheckoutSession::Result.new(
          payment: instance_double(EnterprisePayment),
          session: stripe_session
        )
      end

      before do
        allow(Enterprise::PaymentProviders::Stripe)
          .to receive(:create_checkout_session)
          .and_return(checkout_result)
      end

      it 'starts the configured credit-card provider and leaves Pro inactive until the webhook completes' do
        post :create, params: { payment_method: 'credit_card' }

        account.reload
        expect(account.plan).to eq('inactive')
        expect(account.paid_until).to be_nil
        expect(Enterprise::PaymentProviders::Stripe).to have_received(:create_checkout_session).with(
          enterprise_account: account,
          user: user,
          success_url: a_string_matching(%r{/enterprise/pay/success\?session_id=\{CHECKOUT_SESSION_ID\}}),
          cancel_url: 'http://test.host/enterprise/pay/cancel'
        )
        expect(response).to redirect_to('https://checkout.stripe.com/c/pay/cs_test')
        expect(response).to have_http_status(:see_other)
      end

      it 'redirects back when Stripe Checkout cannot be started' do
        allow(Enterprise::PaymentProviders::Stripe)
          .to receive(:create_checkout_session)
          .and_raise(Enterprise::PaymentProviders::Stripe::ConfigurationError, 'Stripe is not configured.')

        post :create, params: { payment_method: 'credit_card' }

        expect(account.reload.plan).to eq('inactive')
        expect(response).to redirect_to(enterprise_settings_path)
        expect(flash[:alert]).to eq('Stripe is not configured.')
      end

      it 'does not start another checkout while a card payment is pending' do
        create(:enterprise_payment, enterprise_account: account, user: user)

        post :create, params: { payment_method: 'credit_card' }

        expect(Enterprise::PaymentProviders::Stripe).not_to have_received(:create_checkout_session)
        expect(response).to redirect_to(enterprise_status_path)
        expect(flash[:alert]).to match(/already have a card payment/)
      end
    end

    context 'choosing invoice' do
      it 'stays inactive, notifies admins, and redirects to settings' do
        post :create, params: { payment_method: 'invoice' }

        account.reload
        expect(account.plan).to eq('inactive')
        expect(account.payment_method).to eq('invoice')
        expect(Enterprise::RegistrationMailer).to have_received(:admin_payment).with(account, user)
        expect(response).to redirect_to(enterprise_settings_path)
      end

      it 'requires a pending card payment to be canceled before changing methods' do
        create(:enterprise_payment, enterprise_account: account, user: user)

        post :create, params: { payment_method: 'invoice' }

        expect(account.reload.payment_method).to be_nil
        expect(Enterprise::RegistrationMailer).not_to have_received(:admin_payment)
        expect(response).to redirect_to(enterprise_status_path)
        expect(flash[:alert]).to match(/Cancel your pending card payment/)
      end
    end

    context 'with no payment method' do
      it 'redirects back with an alert' do
        post :create, params: {}

        expect(account.reload.plan).to eq('inactive')
        expect(response).to redirect_to(enterprise_settings_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'when the user has not confirmed their email' do
      let(:user) { create(:user, :enterprise, :unconfirmed_enterprise_email, enterprise_account: account) }

      it 'denies access' do
        post :create, params: { payment_method: 'credit_card' }

        expect(response).to redirect_to(root_path)
        expect(account.reload.plan).to eq('inactive')
      end
    end
  end

  describe '#success' do
    context 'when the webhook has activated Pro' do
      let(:account) { create(:enterprise_account, plan: 'pro') }

      it 'sends the user to enterprise notices' do
        get :success

        expect(response).to redirect_to(controller.enterprise_my_notices_path)
        expect(flash[:notice]).to match(/Payment received/)
      end
    end

    context 'when Stripe is still confirming the payment' do
      it 'sends the user to the status page' do
        get :success

        expect(response).to redirect_to(enterprise_status_path)
        expect(flash[:notice]).to match(/Stripe is confirming/)
      end
    end
  end

  describe '#cancel' do
    before do
      allow(Enterprise::PaymentProviders::Stripe)
        .to receive(:cancel_payment)
        .and_return(:canceled)
    end

    it 'returns the user to settings' do
      get :cancel

      expect(response).to redirect_to(enterprise_settings_path)
      expect(flash[:notice]).to match(/canceled/)
    end

    it 'cancels a pending payment before returning to settings' do
      payment = create(:enterprise_payment, enterprise_account: account, user: user)

      get :cancel

      expect(Enterprise::PaymentProviders::Stripe).to have_received(:cancel_payment).with(payment: payment)
      expect(response).to redirect_to(enterprise_settings_path)
    end
  end

  describe '#cancel_pending' do
    before do
      allow(Enterprise::PaymentProviders::Stripe)
        .to receive(:cancel_payment)
        .and_return(:canceled)
    end

    it 'cancels the current pending card payment and returns to settings' do
      payment = create(:enterprise_payment, enterprise_account: account, user: user)

      post :cancel_pending

      expect(Enterprise::PaymentProviders::Stripe).to have_received(:cancel_payment).with(payment: payment)
      expect(response).to redirect_to(enterprise_settings_path)
      expect(flash[:notice]).to match(/start a new payment/)
    end

    it 'redirects to status when there is no pending payment' do
      post :cancel_pending

      expect(Enterprise::PaymentProviders::Stripe).not_to have_received(:cancel_payment)
      expect(response).to redirect_to(enterprise_status_path)
      expect(flash[:alert]).to match(/no pending payment/)
    end
  end
end
