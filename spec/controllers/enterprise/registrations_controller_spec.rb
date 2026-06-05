require 'rails_helper'

describe Enterprise::RegistrationsController do
  render_views

  def registration_params(overrides = {})
    {
      enterprise_registration: {
        email: 'rep@example.com',
        password: 'secretsauce',
        password_confirmation: 'secretsauce',
        company_name: 'Example Business',
        company_contact_information: '123 Main St',
        representative_contact_information: 'Jane Rep, jane@example.com',
        payment_method: 'invoice'
      }.merge(overrides)
    }
  end

  describe '#new' do
    it 'renders the registration form' do
      get :new

      expect(response).to be_successful
      expect(assigns(:registration)).to be_an_instance_of(EnterpriseRegistration)
    end
  end

  describe '#create' do
    context 'when the captcha fails' do
      before { allow(controller).to receive(:verify_recaptcha).and_return(false) }

      it 'does not create anything and re-renders the form' do
        post :create, params: registration_params

        expect(User.count).to eq(0)
        expect(EnterpriseAccount.count).to eq(0)
        expect(response).to be_successful
        expect(flash.now[:alert]).to be_present
      end
    end

    context 'when the captcha passes' do
      before { allow(controller).to receive(:verify_recaptcha).and_return(true) }

      context 'with a credit card registration' do
        it 'creates a pro account, assigns the enterprise role, signs in and redirects to my notices' do
          post :create, params: registration_params(payment_method: 'credit_card')

          user = User.find_by(email: 'rep@example.com')
          account = user.enterprise_account

          expect(user.role?(:enterprise)).to be true
          expect(account.plan).to eq('pro')
          expect(account.paid_until).to be_within(1.minute).of(1.month.from_now)
          expect(controller.current_user).to eq(user)
          expect(response).to redirect_to(controller.enterprise_my_notices_path)
          expect(flash[:notice]).to match(/Lumen Enterprise/i)
        end
      end

      context 'with an invoice registration' do
        it 'creates an inactive account, assigns the enterprise role and redirects to the status page' do
          post :create, params: registration_params(payment_method: 'invoice')

          user = User.find_by(email: 'rep@example.com')
          account = user.enterprise_account

          expect(user.role?(:enterprise)).to be true
          expect(account.plan).to eq('inactive')
          expect(account.paid_until).to be_nil
          expect(response).to redirect_to(enterprise_status_path)
        end
      end

      context 'with a duplicate email' do
        before { create(:user, email: 'rep@example.com') }

        it 'shows a friendly error and creates no new records' do
          post :create, params: registration_params

          expect(User.count).to eq(1)
          expect(EnterpriseAccount.count).to eq(0)
          expect(response).to be_successful
          expect(assigns(:registration).errors[:email].join).to match(/taken/i)
        end
      end
    end
  end
end
