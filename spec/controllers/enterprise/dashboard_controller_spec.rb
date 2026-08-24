require 'rails_helper'

describe Enterprise::DashboardController do
  render_views

  let(:enterprise_account) { create(:enterprise_account) }
  let(:user) { create(:user, :enterprise, enterprise_account: enterprise_account) }
  let(:dashboard) do
    instance_double(
      Lumen::Enterprise::Dashboard,
      total_notices: 12,
      notices_last_seven_days: 4,
      daily_activity: { Date.new(2026, 8, 22) => 4 },
      notice_types: { 'DMCA' => 12 },
      recent_notices: []
    )
  end

  before do
    create(:enterprise_domain, enterprise_account: enterprise_account, domain: 'example.com')
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(Lumen::Enterprise::Dashboard).to receive(:new).and_return(dashboard)
  end

  it 'renders an account-scoped overview' do
    get :show

    expect(response).to be_successful
    expect(response.body).to include('Monitor your domains at a glance')
    expect(response.body).to include('Recent notices')
    expect(response.body).to include('example.com')
  end

  it 'denies dashboard access to inactive accounts' do
    inactive_account = create(:enterprise_account, :inactive)
    inactive_user = create(:user, :enterprise, enterprise_account: inactive_account)
    allow(controller).to receive(:current_user).and_return(inactive_user)

    get :show

    expect(response).to redirect_to(root_path)
  end
end
