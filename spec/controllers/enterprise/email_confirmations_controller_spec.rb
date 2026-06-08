require 'rails_helper'

describe Enterprise::EmailConfirmationsController do
  render_views

  let(:account) { create(:enterprise_account, :inactive) }
  let(:user) do
    create(:user, :enterprise, :unconfirmed_enterprise_email,
           email: 'rep@example.com', enterprise_account: account)
  end

  describe '#show' do
    it 'renders the set-password form for a valid token' do
      get :show, params: { token: user.enterprise_email_confirmation_token }

      expect(response).to be_successful
      expect(assigns(:user)).to eq(user)
    end

    it 'redirects to sign in for an unknown token' do
      get :show, params: { token: 'nope' }

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe '#update' do
    it 'sets the password, confirms the email, signs in, notifies admins, and redirects to settings' do
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      expect(Enterprise::RegistrationMailer)
        .to receive(:admin_email_confirmed).with(account, user).and_return(mailer)

      patch :update, params: {
        token: user.enterprise_email_confirmation_token,
        user: { password: 'newsecret123', password_confirmation: 'newsecret123' }
      }

      user.reload
      expect(user.enterprise_email_confirmed?).to be true
      expect(user.enterprise_email_confirmation_token).to be_nil
      expect(user.valid_password?('newsecret123')).to be true
      expect(controller.current_user).to eq(user)
      expect(response).to redirect_to(enterprise_settings_path)
    end

    it 're-renders the form when the passwords do not match' do
      patch :update, params: {
        token: user.enterprise_email_confirmation_token,
        user: { password: 'newsecret123', password_confirmation: 'different' }
      }

      expect(user.reload.enterprise_email_confirmed?).to be false
      expect(response).to be_successful
    end

    it 'redirects to sign in for an unknown token' do
      patch :update, params: {
        token: 'nope',
        user: { password: 'newsecret123', password_confirmation: 'newsecret123' }
      }

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
