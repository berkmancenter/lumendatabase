require 'rails_helper'

describe 'enterprise/settings/show.html.erb' do
  let(:current_user) { build_stubbed(:user, email: 'client@example.com') }

  before do
    allow(view).to receive(:current_user).and_return(current_user)
    assign(:pending_payment, nil)
  end

  it 'shows enterprise account data without editable fields' do
    assign(
      :enterprise_account,
      build_stubbed(
        :enterprise_account,
        plan: 'pro',
        applicant_email: 'rep@example.com',
        company_contact_information: "Example Business\n1 Example Way",
        representative_contact_information: "Jane Representative\njane@example.com",
        interested_domains: "example.com\nexample.org"
      )
    )

    render

    expect(rendered).to have_css('h1', text: 'Account')
    expect(rendered).to have_css('h3', text: 'Enterprise data')
    expect(rendered).to have_css('.enterprise-account-details', text: 'Example Business')
    expect(rendered).to have_css('.enterprise-account-details', text: 'rep@example.com')
    expect(rendered).to have_css('.enterprise-account-details', text: '1 Example Way')
    expect(rendered).to have_css('.enterprise-account-details', text: 'jane@example.com')
    expect(rendered).not_to have_css('.enterprise-account-details', text: 'Interested domains')
    expect(rendered).not_to have_css('input[name="enterprise_account[name]"]')
  end

  it 'shows the plan, payment method, and how long Pro access is active' do
    assign(
      :enterprise_account,
      build_stubbed(
        :enterprise_account,
        plan: 'pro',
        payment_method: 'credit_card',
        paid_until: Time.utc(2026, 7, 1, 12, 0, 0)
      )
    )

    render

    expect(rendered).to have_css('.enterprise-plan', text: /Pro/)
    expect(rendered).to have_css('.enterprise-plan-payment-method', text: /Credit card/)
    expect(rendered).to have_css(
      '.enterprise-plan-active-until',
      text: /active until July 01, 2026/,
      normalize_ws: true
    )
  end

  it 'shows invoice status for an inactive invoice account' do
    assign(:enterprise_account, build_stubbed(:enterprise_account, :inactive, :invoice))

    render

    expect(rendered).to have_css('h3', text: "Your Lumen Enterprise account isn't active yet")
    expect(rendered).to match(/set up to be invoiced/i)
    expect(rendered).not_to have_button('Get Pro')
  end

  it 'shows a pending card payment and its cancel action' do
    assign(:enterprise_account, build_stubbed(:enterprise_account, :inactive, :credit_card))
    assign(:pending_payment, build_stubbed(:enterprise_payment, amount_cents: 50_000))

    render

    expect(rendered).to include('card payment in progress')
    expect(rendered).to include('$500.00')
    expect(rendered).to have_button('Cancel pending payment')
    expect(rendered).not_to have_button('Get Pro')
  end
end
