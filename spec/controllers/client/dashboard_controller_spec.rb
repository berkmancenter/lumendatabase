require 'rails_helper'

describe Client::DashboardController do
  let(:enterprise_account) { create(:enterprise_account) }
  let(:user) { create(:user, :enterprise, enterprise_account: enterprise_account) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe '#index' do
    it 'uses the client-scoped notice search path' do
      notices = build_list(:dmca, 2)
      expect(EnterpriseNoticeReport)
        .to receive(:recent)
        .with(enterprise_account)
        .and_return(notices)

      get :index

      expect(response).to be_successful
      expect(assigns(:recent_notices)).to eq(notices)
      expect(assigns(:search_index_path)).to eq(client_notices_search_index_path)
      expect(assigns(:search_all_placeholder)).to eq('Search your domain notices...')
    end
  end
end
