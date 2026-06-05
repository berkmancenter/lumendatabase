require 'rails_helper'

describe 'notices/search/_result.html.erb' do
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(view.controller).to receive(:current_ability) { @ability }
  end

  it 'does not redact verified enterprise domain paths in client highlights' do
    enterprise_account = create(:enterprise_account)
    create(
      :enterprise_domain,
      enterprise_account: enterprise_account,
      domain: 'business.example',
      verified: true
    )
    create(
      :enterprise_domain,
      enterprise_account: enterprise_account,
      domain: 'pending.example',
      verified: false
    )
    user = create(:user, :enterprise, enterprise_account: enterprise_account)
    result = build_stubbed(:dmca)

    allow(result).to receive(:highlight).and_return([
      'URLs https://business.example/<em>private</em> ' \
        'https://pending.example/private https://other.example/private'
    ])
    allow(view).to receive(:enterprise_area?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:params)
      .and_return({ term: 'private' }.with_indifferent_access)

    render partial: 'notices/search/result', locals: { result: result }

    expect(rendered).to include('https://business.example/<em>private</em>')
    expect(rendered).to include('https://pending.example/[REDACTED]')
    expect(rendered).to include('https://other.example/[REDACTED]')
  end

  it 'redacts filtered URL text in highlights' do
    ContentFilter.create!(
      name: 'Sensitive Domain',
      url_text: 'sensitive',
      granularity: 'urls',
      actions: ['full_notice_version_only_researchers']
    )
    work = Work.new(
      infringing_urls: [
        InfringingUrl.new(url: 'https://sensitive-domain.com/private')
      ]
    )
    result = create(:dmca, role_names: %w[sender principal submitter])
    result.works = [work]
    result.save!

    allow(result).to receive(:highlight).and_return([
      'URL https://<em>sensitive</em>-domain.com/private'
    ])
    allow(view).to receive(:enterprise_area?).and_return(false)
    allow(view).to receive(:current_user).and_return(nil)
    allow(view).to receive(:params)
      .and_return({ term: 'sensitive' }.with_indifferent_access)

    render partial: 'notices/search/result', locals: { result: result }

    expect(rendered).to include('https://[REDACTED]-domain.com/[REDACTED]')
    expect(rendered).not_to include('sensitive-domain.com/private')
  end
end
