require 'rails_helper'

describe Enterprise::StatusController do
  render_views

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe '#show' do
    context 'with an inactive credit-card account' do
      let(:account) { create(:enterprise_account, :inactive, :credit_card) }
      let(:user) { create(:user, :enterprise, enterprise_account: account) }

      it 'renders the status page with credit-card guidance' do
        get :show

        expect(response).to be_successful
        expect(response.body).to match(/credit card/i)
        expect(response.body).not_to match(/invoiced/i)
      end
    end

    context 'with an inactive invoice account' do
      let(:account) { create(:enterprise_account, :inactive, :invoice) }
      let(:user) { create(:user, :enterprise, enterprise_account: account) }

      it 'renders the status page with invoice guidance' do
        get :show

        expect(response).to be_successful
        expect(response.body).to match(/invoice/i)
      end
    end

    context 'with a previous Pro subscription' do
      let(:account) do
        create(
          :enterprise_account,
          :inactive,
          :invoice,
          paid_until: 2.days.ago
        )
      end
      let(:user) { create(:user, :enterprise, enterprise_account: account) }

      it 'shows when the most recent Pro subscription was paid through' do
        get :show

        expect(response).to be_successful
        expect(response.body).to include(
          account.paid_until.to_fs(:simple)
        )
        expect(response.body).to match(/most recent Pro subscription/i)
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
  end
end
