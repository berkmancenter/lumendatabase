require 'rails_helper'

describe Enterprise::RegistrationsController do
  render_views

  def registration_params(overrides = {})
    {
      enterprise_registration: {
        email: 'rep@example.com',
        company_name: 'Example Business',
        company_contact_information: '123 Main St',
        representative_contact_information: 'Jane Rep, jane@example.com',
        interested_domains: "example.com\nshop.example.com"
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

        expect(EnterpriseAccount.count).to eq(0)
        expect(response).to be_successful
        expect(flash.now[:alert]).to be_present
      end
    end

    context 'when the captcha passes' do
      before { allow(controller).to receive(:verify_recaptcha).and_return(true) }

      it 'creates a pre_registration account, no user, no session, and redirects to the received page' do
        post :create, params: registration_params

        account = EnterpriseAccount.find_by(applicant_email: 'rep@example.com')

        expect(account.status).to eq('pre_registration')
        expect(account.plan).to eq('inactive')
        expect(account.interested_domains).to eq("example.com\nshop.example.com")
        expect(User.count).to eq(0)
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to(enterprise_registration_received_path)
      end
    end
  end

  describe '#received' do
    it 'renders the acknowledgement page' do
      get :received

      expect(response).to be_successful
    end
  end
end
