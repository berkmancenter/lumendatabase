require 'rails_helper'

describe Enterprise::StatusController do
  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe '#show' do
    context 'with a confirmed not-yet-pro account' do
      let(:account) { create(:enterprise_account, :inactive, :invoice) }
      let(:user) { create(:user, :enterprise, enterprise_account: account) }

      it 'redirects to settings' do
        get :show

        expect(response).to redirect_to(enterprise_settings_path)
      end
    end

    context 'when the account is already on the pro plan' do
      let(:account) { create(:enterprise_account, plan: 'pro') }
      let(:user) { create(:user, :enterprise, enterprise_account: account) }

      it 'redirects to enterprise notices' do
        get :show

        expect(response).to redirect_to(
          enterprise_notices_search_index_path(sort_by: 'created_at desc')
        )
      end
    end

    context 'with an unconfirmed enterprise user' do
      let(:account) { create(:enterprise_account, :inactive) }
      let(:user) do
        create(
          :user,
          :enterprise,
          :unconfirmed_enterprise_email,
          enterprise_account: account
        )
      end

      it 'redirects home' do
        get :show

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Enterprise access is not active for this account.')
      end
    end
  end
end
