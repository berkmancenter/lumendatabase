require 'rails_helper'

describe Enterprise::SettingsController do
  render_views

  let(:enterprise_account) { create(:enterprise_account) }
  let(:user) { create(:user, :enterprise, enterprise_account: enterprise_account) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'access control' do
    it 'denies settings access to users who have not confirmed their email' do
      unconfirmed = create(:user, :enterprise, :unconfirmed_enterprise_email, enterprise_account: enterprise_account)
      allow(controller).to receive(:current_user).and_return(unconfirmed)

      get :show

      expect(response).to redirect_to(root_path)
    end

    it 'lets a confirmed not-yet-pro user reach settings to choose a plan' do
      inactive_account = create(:enterprise_account, :inactive)
      inactive_user = create(:user, :enterprise, enterprise_account: inactive_account)
      allow(controller).to receive(:current_user).and_return(inactive_user)

      get :show

      expect(response).to be_successful
      expect(response.body).to include('Get Pro')
    end
  end

  describe '#show' do
    it 'lists domains for the current client' do
      verified_domain = create(:enterprise_domain, enterprise_account: enterprise_account, domain: 'example.com')
      pending_domain = create(:enterprise_domain, enterprise_account: enterprise_account, domain: 'pending.example', verified: false)

      get :show

      expect(response).to be_successful
      expect(assigns(:enterprise_domains)).to eq([verified_domain, pending_domain])
      expect(response.body).to include(pending_domain.verification_filename)
      expect(response.body).to include(pending_domain.verification_file_content)
    end
  end

  describe '#update' do
    it 'updates report settings' do
      patch :update, params: {
        enterprise_account: {
          report_frequency: 'weekly',
          report_recipient_email: 'reports@example.com'
        }
      }

      enterprise_account.reload

      expect(enterprise_account.report_frequency).to eq('weekly')
      expect(enterprise_account.report_recipient_email).to eq('reports@example.com')
      expect(response).to redirect_to(enterprise_settings_path)
    end
  end
end
