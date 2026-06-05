require 'rails_helper'

describe 'enterprise/settings/show.html.erb' do
  let(:current_user) { build_stubbed(:user, email: 'client@example.com') }

  before do
    allow(view).to receive(:current_user).and_return(current_user)
    allow(view).to receive(:enterprise_my_notices_path)
      .and_return(enterprise_notices_search_index_path(sort_by: 'created_at desc'))
    assign(:enterprise_domains, [])
  end

  it 'shows the plan, payment method, and how long Pro access is active' do
    assign(
      :enterprise_account,
      build_stubbed(
        :enterprise_account,
        plan: 'pro',
        payment_method: 'credit_card',
        paid_until: Time.utc(2026, 7, 1, 12, 0, 0),
        report_frequency: 'none'
      )
    )

    render

    expect(rendered).to have_css('.enterprise-plan', text: /Pro/)
    expect(rendered).to have_css(
      '.enterprise-plan-payment-method',
      text: /Credit card/
    )
    expect(rendered).to have_css(
      '.enterprise-plan-active-until',
      text: /active until July 01, 2026/,
      normalize_ws: true
    )
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
