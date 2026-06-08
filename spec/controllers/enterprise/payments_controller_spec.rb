require 'rails_helper'

describe Enterprise::PaymentsController do
  let(:account) { create(:enterprise_account, :inactive) }
  let(:user) { create(:user, :enterprise, enterprise_account: account) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(Enterprise::RegistrationMailer).to receive(:admin_payment)
      .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
    allow(Enterprise::RegistrationMailer).to receive(:client_confirmation)
      .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
  end

  describe '#create' do
    context 'paying by credit card' do
      it 'activates Pro, notifies admins, and redirects to my notices' do
        post :create, params: { payment_method: 'credit_card' }

        account.reload
        expect(account.plan).to eq('pro')
        expect(account.payment_method).to eq('credit_card')
        expect(account.paid_until).to be_within(1.minute).of(1.month.from_now)
        expect(Enterprise::RegistrationMailer).to have_received(:admin_payment).with(account, user)
        expect(response).to redirect_to(controller.enterprise_my_notices_path)
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
end
