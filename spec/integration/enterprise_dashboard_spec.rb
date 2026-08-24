require 'rails_helper'

feature 'Enterprise dashboard' do
  scenario 'an enterprise user signs in to the console overview' do
    account = create(:enterprise_account, name: 'Acme Rights')
    create(:enterprise_domain, enterprise_account: account, domain: 'acme.example')
    user = create(
      :user,
      :enterprise,
      enterprise_account: account,
      email: 'enterprise@example.com'
    )
    dashboard = instance_double(
      Lumen::Enterprise::Dashboard,
      total_notices: 14,
      notices_last_seven_days: 5,
      daily_activity: {
        Date.new(2026, 8, 22) => 4,
        Date.new(2026, 8, 23) => 5
      },
      notice_types: { 'DMCA' => 12, 'Trademark' => 2 },
      recent_notices: []
    )
    allow(Lumen::Enterprise::Dashboard).to receive(:new).and_return(dashboard)

    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'secretsauce'
    click_button 'Log in'

    expect(page).to have_current_path(enterprise_root_path)
    expect(page).to have_css('.enterprise-shell')
    expect(page).to have_css('.enterprise-nav-link.is-active', text: 'Overview')
    expect(page).to have_content('Monitor your domains at a glance')
    expect(page).to have_content('Acme Rights')
    expect(page).to have_content('acme.example')

    within('.enterprise-sidebar') { click_link 'Reports' }
    expect(page).to have_current_path(enterprise_reports_path)
    expect(page).to have_css('h1', text: 'Reports')

    within('.enterprise-sidebar') { click_link 'Domains' }
    expect(page).to have_current_path(enterprise_domains_path)
    expect(page).to have_css('h1', text: 'Domains')

    within('.enterprise-sidebar') { click_link 'Account' }
    expect(page).to have_current_path(enterprise_account_path)
    expect(page).to have_css('h1', text: 'Account')
  end
end
