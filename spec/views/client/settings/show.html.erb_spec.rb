require 'rails_helper'

describe 'client/settings/show.html.erb' do
  let(:current_user) { build_stubbed(:user, email: 'client@example.com') }

  before do
    allow(view).to receive(:current_user).and_return(current_user)
    allow(view).to receive(:client_my_notices_path)
      .and_return(client_notices_search_index_path(sort_by: 'created_at desc'))
    assign(:verified_domains, [])
  end

  it 'labels report frequency as Status with Off, Daily, and Weekly options' do
    assign(
      :enterprise_account,
      build_stubbed(:enterprise_account, report_frequency: 'none')
    )

    render

    expect(rendered).to have_css('div.inner-padding')
    expect(rendered).to have_css(
      'label[for="enterprise_account_report_frequency"]',
      text: 'Status'
    )
    expect(rendered).not_to include('Cadence')
    expect(rendered).to have_css('option[value="none"]', text: 'Off')
    expect(rendered).to have_css('option[value="daily"]', text: 'Daily')
    expect(rendered).to have_css('option[value="weekly"]', text: 'Weekly')
  end

  it 'hides the delivery email field when report status is off' do
    assign(
      :enterprise_account,
      build_stubbed(:enterprise_account, report_frequency: 'none')
    )

    render

    expect(rendered).to have_css(
      '#enterprise-report-recipient[hidden]',
      visible: :all
    )
    expect(rendered).to have_css(
      '#enterprise_account_report_recipient_email[disabled]',
      visible: :all
    )
  end

  it 'shows the delivery email field when report status is daily' do
    assign(
      :enterprise_account,
      build_stubbed(:enterprise_account, report_frequency: 'daily')
    )

    render

    expect(rendered).to have_css('#enterprise-report-recipient')
    expect(rendered).not_to have_css(
      '#enterprise-report-recipient[hidden]',
      visible: :all
    )
    expect(rendered).not_to have_css(
      '#enterprise_account_report_recipient_email[disabled]',
      visible: :all
    )
  end
end
