require 'rails_helper'

describe 'enterprise/reports/index.html.erb' do
  let(:current_user) { build_stubbed(:user, email: 'client@example.com') }
  let(:enterprise_account) do
    build_stubbed(:enterprise_account, plan: 'pro', report_frequency: 'none')
  end

  before do
    allow(view).to receive(:current_user).and_return(current_user)
    assign(:enterprise_account, enterprise_account)
    assign(:enterprise_reports, [])
  end

  it 'shows recurring delivery controls on the reports page' do
    render

    expect(rendered).to have_css('h1', text: 'Reports')
    expect(rendered).to include('Receive notices matching your verified domains automatically.')
    expect(rendered).to have_css(
      'label[for="enterprise_account_report_frequency"]',
      text: 'Frequency'
    )
    expect(rendered).to have_css('option[value="none"]', text: 'Off')
    expect(rendered).to have_css('option[value="daily"]', text: 'Daily')
    expect(rendered).to have_css('option[value="weekly"]', text: 'Weekly')
    expect(rendered).to have_css('#enterprise-report-recipient[hidden]', visible: :all)
    expect(rendered).to have_css(
      '#enterprise_account_report_recipient_email[disabled]',
      visible: :all
    )
  end

  it 'shows the delivery email when recurring reports are enabled' do
    assign(
      :enterprise_account,
      build_stubbed(:enterprise_account, plan: 'pro', report_frequency: 'daily')
    )

    render

    expect(rendered).not_to have_css('#enterprise-report-recipient[hidden]', visible: :all)
    expect(rendered).not_to have_css(
      '#enterprise_account_report_recipient_email[disabled]',
      visible: :all
    )
  end

  it 'shows the on-demand report form and an empty history state' do
    render

    expect(rendered).to have_css(
      "form[action=\"#{enterprise_reports_path}\"][method=\"post\"]"
    )
    expect(rendered).to have_css('input[name="enterprise_report[starts_on]"][type="date"]')
    expect(rendered).to have_css('input[name="enterprise_report[ends_on]"][type="date"]')
    expect(rendered).to have_button('Request report')
    expect(rendered).to have_css('.enterprise-report-history', text: 'No report requests yet')
  end
end
