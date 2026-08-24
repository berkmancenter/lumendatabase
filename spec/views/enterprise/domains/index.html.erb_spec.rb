require 'rails_helper'

describe 'enterprise/domains/index.html.erb' do
  before do
    assign(:enterprise_account, build_stubbed(:enterprise_account, plan: 'pro'))
    assign(:enterprise_domains, [])
    assign(:domain_auto_verification_enabled, false)
  end

  it 'shows the domain form and empty state' do
    render

    expect(rendered).to have_css('h1', text: 'Domains')
    expect(rendered).to have_css(
      "form[action=\"#{enterprise_domains_path}\"][method=\"post\"]"
    )
    expect(rendered).to have_field('Add a domain')
    expect(rendered).to have_css('.enterprise-domains-empty', text: 'No domains yet')
  end

  it 'shows verification instructions for a pending domain' do
    enterprise_domain = build_stubbed(:enterprise_domain, verified: false)
    assign(:enterprise_domains, [enterprise_domain])

    render

    expect(rendered).to have_button('Verify now')
    expect(rendered).to include(enterprise_domain.verification_filename)
    expect(rendered).to include(enterprise_domain.verification_file_content)
  end

  it 'hides manual verification in auto-verification mode' do
    assign(:enterprise_domains, [build_stubbed(:enterprise_domain, verified: false)])
    assign(:domain_auto_verification_enabled, true)

    render

    expect(rendered).not_to have_button('Verify now')
    expect(rendered).not_to include('on this domain with this exact content:')
    expect(rendered).not_to include('lumen-domain-verification-')
  end
end
