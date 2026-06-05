require 'spec_helper'

describe NoticesHelper do
  include NoticesHelper

  it 'returns correct form partials' do
    # Not testing every one of these in the interests of test speed, but
    # checking both a one-word and a multi-word notice type.
    expect(helper.form_partial_for(build(:dmca))).to eq 'dmca_form'
    expect(helper.form_partial_for(build(:law_enforcement_request)))
      .to eq 'law_enforcement_request_form'
  end

  it 'returns correct show partials' do
    expect(helper.show_partial_for(build(:dmca))).to eq 'dmca_show'
    expect(helper.show_partial_for(build(:law_enforcement_request)))
      .to eq 'law_enforcement_request_show'
  end

  it 'returns correct works partials' do
    expect(helper.works_partial_for(build(:dmca))).to eq 'dmca_works'
    expect(helper.works_partial_for(build(:law_enforcement_request)))
      .to eq 'law_enforcement_request_works'
  end

  it 'displays date_received correctly' do
    now = Time.utc(2018, 12, 21, 0, 0, 0)
    dmca = build(:dmca, date_received: now)
    expect(helper.date_received(dmca))
      .to eq '<time datetime="2018-12-21T00:00:00Z">December 21, 2018</time>'
  end

  it 'handles missing date_received' do
    dmca = build(:dmca, date_received: nil)
    expect(helper.date_received(dmca)).to be nil
  end

  it 'displays date_sent correctly' do
    now = Time.utc(2018, 12, 21, 0, 0, 0)
    dmca = build(:dmca, date_sent: now)
    expect(helper.date_sent(dmca))
      .to eq '<time datetime="2018-12-21T00:00:00Z">December 21, 2018</time>'
  end

  it 'handles missing date_sent' do
    dmca = build(:dmca, date_sent: nil)
    expect(helper.date_sent(dmca)).to be nil
  end

  it 'displays notice subjects' do
    subject = 'Cockapoos vs corgis: go'
    dmca = build(:dmca, subject: subject)
    expect(helper.subject(dmca)).to eq subject
  end

  it 'handles missing notice subjects' do
    dmca = build(:dmca, subject: nil)
    expect(helper.subject(dmca)).to eq 'Unknown'
  end

  it 'correctly labels URL inputs' do
    court_order = build(:court_order)
    data_protection = build(:data_protection)
    defamation = build(:defamation)
    dmca = build(:dmca)
    law_enforcement = build(:law_enforcement_request)
    local_law = build(:local_law)
    other = build(:other)
    private_information = build(:private_information)
    trademark = build(:trademark)

    expect(helper.label_for_url_input(:infringing_urls, court_order))
      .to eq 'Targeted URL'
    expect(helper.label_for_url_input(:infringing_urls, data_protection))
      .to eq Translation.t('notice_show_works_law_enf_gov_infringing_url_label')
    expect(helper.label_for_url_input(:infringing_urls, defamation))
      .to eq 'Allegedly Defamatory URL'
    expect(helper.label_for_url_input(:infringing_urls, dmca))
      .to eq 'Allegedly Infringing URL'
    expect(helper.label_for_url_input(:infringing_urls, law_enforcement))
      .to eq Translation.t('notice_show_works_law_enf_gov_infringing_url_label')
    expect(helper.label_for_url_input(:infringing_urls, local_law))
      .to eq Translation.t('notice_show_works_problematic_urls')
    expect(helper.label_for_url_input(:infringing_urls, other))
      .to eq 'Problematic URL'
    expect(helper.label_for_url_input(:infringing_urls, private_information))
      .to eq 'URL with private information'
    expect(helper.label_for_url_input(:infringing_urls, trademark))
      .to eq 'Allegedly Infringing URL'

    expect(helper.label_for_url_input(:copyrighted_urls, dmca))
      .to eq 'Original Work URL'
    expect(helper.label_for_url_input(:copyrighted_urls, law_enforcement))
      .to eq Translation.t('notice_show_works_law_enf_gov_copyrighted_url_label')
    expect(helper.label_for_url_input(:copyrighted_urls, other))
      .to eq 'Original Work URL'
  end

  it 'handles bogus URL types' do
    dmca = build(:dmca)
    expect { helper.label_for_url_input(:party_time_urls, dmca) }
      .to raise_error(RuntimeError)
  end

  describe '#access_requestable?' do
    it 'allows request access when a limited notice has requestable URLs' do
      notice = build(:dmca)

      allow(helper).to receive(:confidential_order?).with(notice).and_return(false)
      allow(helper).to receive(:current_user).and_return(nil)

      expect(helper.access_requestable?(notice, false, true)).to be true
    end

    it 'does not allow request access for an enterprise user viewing their domain notice' do
      enterprise_account = create(:enterprise_account)
      create(
        :enterprise_domain,
        enterprise_account: enterprise_account,
        domain: 'business.example',
        verified: true
      )
      user = create(:user, :enterprise, enterprise_account: enterprise_account)
      notice = build(
        :dmca,
        works: [
          Work.new(
            infringing_urls: [
              InfringingUrl.new(url: 'https://business.example/private')
            ]
          )
        ]
      )

      allow(helper).to receive(:confidential_order?).with(notice).and_return(false)
      allow(helper).to receive(:current_user).and_return(user)

      expect(helper.access_requestable?(notice, false, true)).to be false
    end
  end

  it 'redacts URL paths in rendered text' do
    text = 'Body URL: http://some-tld.com/private/page?token=123.'

    expect(helper.redact_url_paths(text))
      .to eq 'Body URL: http://some-tld.com/[REDACTED].'
  end

  it 'redacts multiple rendered URLs while preserving each host' do
    text = 'See https://example.com/a and http://media.example.org/video.mp4'
    redacted_text =
      'See https://example.com/[REDACTED] and http://media.example.org/[REDACTED]'

    expect(helper.redact_url_paths(text)).to eq redacted_text
  end

  it 'does not redact URL paths for configured domains' do
    text = 'See https://business.example/private and https://other.example/private.'
    redacted_text =
      'See https://business.example/private and https://other.example/[REDACTED].'

    expect(helper.redact_url_paths(text, unredacted_domains: ['business.example']))
      .to eq redacted_text
  end

  it 'does not redact verified enterprise domains in client search highlights' do
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
    highlight = 'URLs https://business.example/<em>private</em> ' \
                'https://pending.example/private https://other.example/private'

    allow(helper).to receive(:can?)
      .with(:view_full_version, Notice)
      .and_return(false)
    allow(helper).to receive(:enterprise_area?).and_return(true)
    allow(helper).to receive(:current_user).and_return(user)
    allow(helper).to receive(:params)
      .and_return({ term: 'private' }.with_indifferent_access)

    result = helper.search_result_highlight_text(highlight)

    expect(result).to include('https://business.example/<em>private</em>')
    expect(result).to include('https://pending.example/[REDACTED]')
    expect(result).to include('https://other.example/[REDACTED]')
  end

  it 'redacts verified enterprise domains outside client search highlights' do
    enterprise_account = create(:enterprise_account)
    create(
      :enterprise_domain,
      enterprise_account: enterprise_account,
      domain: 'business.example',
      verified: true
    )
    user = create(:user, :enterprise, enterprise_account: enterprise_account)
    highlight = 'URL https://business.example/<em>private</em>'

    allow(helper).to receive(:can?)
      .with(:view_full_version, Notice)
      .and_return(false)
    allow(helper).to receive(:enterprise_area?).and_return(false)
    allow(helper).to receive(:current_user).and_return(user)
    allow(helper).to receive(:params)
      .and_return({ term: 'private' }.with_indifferent_access)

    expect(helper.search_result_highlight_text(highlight))
      .to include('https://business.example/[REDACTED]')
  end

  it 'does not redact search highlight URLs matching Lumen-team-only filters for admins' do
    ContentFilter.create!(
      name: 'Sensitive Domain',
      url_text: 'sensitive',
      granularity: 'urls',
      actions: ['full_notice_version_only_lumen_team']
    )
    work = Work.new(
      infringing_urls: [
        InfringingUrl.new(url: 'https://sensitive-domain.com/private')
      ]
    )
    notice = create(:dmca, role_names: %w[sender principal submitter])
    notice.works = [work]
    notice.save!
    user = create(:user, :admin)
    highlight = 'URL https://<em>sensitive</em>-domain.com/private'

    allow(helper).to receive(:can?)
      .with(:view_full_version, Notice)
      .and_return(true)
    allow(helper).to receive(:current_user).and_return(user)
    allow(helper).to receive(:params)
      .and_return({ term: 'sensitive' }.with_indifferent_access)

    result = helper.search_result_highlight_text(highlight, notice)

    expect(result).to include('https://<em>sensitive</em>-domain.com/private')
    expect(result).not_to include('[REDACTED]')
  end

  it 'redacts search highlight URLs matching researcher-only filters for public users' do
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
    notice = create(:dmca, role_names: %w[sender principal submitter])
    notice.works = [work]
    notice.save!
    highlight = 'URL https://<em>sensitive</em>-domain.com/private'

    allow(helper).to receive(:can?)
      .with(:view_full_version, Notice)
      .and_return(false)
    allow(helper).to receive(:current_user).and_return(nil)
    allow(helper).to receive(:enterprise_area?).and_return(false)
    allow(helper).to receive(:params)
      .and_return({ term: 'sensitive' }.with_indifferent_access)

    result = helper.search_result_highlight_text(highlight, notice)

    expect(result).to include('https://[REDACTED]-domain.com/[REDACTED]')
    expect(result).not_to include('sensitive-domain.com/private')
  end

  it 'forces path redaction on all highlight URLs when notice has full_notice_version_only_lumen_team flag for non-admins' do
    notice = build(:dmca, full_notice_version_only_lumen_team: true)
    highlight = 'URLs https://example.com/private https://other.org/private'

    allow(helper).to receive(:can?)
      .with(:view_full_version, Notice)
      .and_return(true)
    allow(helper).to receive(:current_user).and_return(create(:user, :researcher))
    allow(helper).to receive(:params)
      .and_return({ term: 'private' }.with_indifferent_access)

    result = helper.search_result_highlight_text(highlight, notice)

    expect(result).to include('https://example.com/[REDACTED]')
    expect(result).to include('https://other.org/[REDACTED]')
    expect(result).not_to include('https://example.com/private')
    expect(result).not_to include('https://other.org/private')
  end

  it 'redacts domain url_text from notice-granularity researchers filter for public users' do
    ContentFilter.create!(
      name: 'Sensitive Notice',
      url_text: 'secret',
      granularity: 'notice',
      actions: ['full_notice_version_only_researchers']
    )
    work = Work.new(
      infringing_urls: [
        InfringingUrl.new(url: 'https://secret-corp.com/private'),
        InfringingUrl.new(url: 'https://other.org/private')
      ]
    )
    notice = create(:dmca, role_names: %w[sender principal submitter])
    notice.works = [work]
    notice.save!
    highlight = 'URLs https://secret-corp.com/private https://other.org/private'

    allow(helper).to receive(:can?)
      .with(:view_full_version, Notice)
      .and_return(false)
    allow(helper).to receive(:current_user).and_return(nil)
    allow(helper).to receive(:enterprise_area?).and_return(false)
    allow(helper).to receive(:params)
      .and_return({ term: 'private' }.with_indifferent_access)

    result = helper.search_result_highlight_text(highlight, notice)

    expect(result).to include('https://[REDACTED]-corp.com/[REDACTED]')
    expect(result).to include('https://other.org/[REDACTED]')
    expect(result).not_to include('secret-corp.com')
    expect(result).not_to include('/private')
  end

  it 'reveals matching enterprise rows for copyrighted URLs' do
    enterprise_account = create(:enterprise_account)
    create(
      :enterprise_domain,
      enterprise_account: enterprise_account,
      domain: 'business.example',
      verified: true
    )
    user = create(:user, :enterprise, enterprise_account: enterprise_account)
    work = Work.new(
      copyrighted_urls: [
        CopyrightedUrl.new(url: 'https://business.example/original')
      ]
    )
    notice = build(:dmca, works: [work])

    allow(helper).to receive(:current_user).and_return(user)

    rows = helper.enterprise_url_rows(work, 'copyrighted', notice)

    expect(rows.map(&:text)).to eq ['https://business.example/original']
    expect(rows.map(&:url)).to eq ['https://business.example/original']
    expect(rows.map(&:full)).to eq [true]
    expect(rows.map(&:researchers_only)).to eq [false]
  end

  it 'does not redact URL paths when the full notice can be seen' do
    notice = build(:dmca)
    text = 'Body URL: http://some-tld.com/private/page?token=123.'
    allow(helper).to receive(:can_see_full_notice_version?)
      .with(notice)
      .and_return(true)

    expect(helper.redact_url_paths_unless_full_notice(notice, text)).to eq text
  end

  it 'redacts URL paths when the full notice cannot be seen' do
    notice = build(:dmca)
    text = 'Body URL: http://some-tld.com/private/page?token=123.'
    allow(helper).to receive(:can_see_full_notice_version?)
      .with(notice)
      .and_return(false)

    expect(helper.redact_url_paths_unless_full_notice(notice, text))
      .to eq 'Body URL: http://some-tld.com/[REDACTED].'
  end

  context 'permanent_url_full_notice' do
    let(:notice) { build(:dmca) }
    let(:user) { build(:user) }

    it 'returns false when no token url is found' do
      allow_any_instance_of(NoticesHelper).to receive(:current_user).and_return(user)

      result = permanent_url_full_notice(notice)

      expect(result).to eq(false)
    end

    it 'returns a proper url when a token url is found' do
      token_url = build_token_url

      allow_any_instance_of(NoticesHelper).to receive(:current_user).and_return(user)

      result = permanent_url_full_notice(notice)

      expect(result).to eq(notice_url(
                             notice,
                             access_token: token_url.token,
                             host: Chill::Application.config.site_host
                           ))
    end

    it 'returns false when current_user is nil' do
      build_token_url

      allow_any_instance_of(NoticesHelper).to receive(:current_user).and_return(nil)

      result = permanent_url_full_notice(notice)

      expect(result).to eq(false)
    end
  end

  private

  def build_token_url
    create(
      :token_url,
      notice: notice,
      user: user,
      valid_forever: true
    )
  end
end
