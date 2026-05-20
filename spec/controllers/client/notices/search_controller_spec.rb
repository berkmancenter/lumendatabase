require 'rails_helper'

describe Client::Notices::SearchController do
  render_views

  let(:enterprise_account) { create(:enterprise_account) }
  let(:user) { create(:user, :enterprise, enterprise_account: enterprise_account) }

  before do
    create(:enterprise_domain, enterprise_account: enterprise_account, domain: 'example.com')
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe '#index' do
    it 'renders the shared notice search view with client filter partials' do
      get :index, params: { term: 'example' }

      expect(response).to be_successful
      expect(response.body).to include('results-facets')
    end
  end
end
