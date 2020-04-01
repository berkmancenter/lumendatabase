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

  it 'displays notice sent_via' do
    source = 'Internet megacorp'
    dmca = build(:dmca, source: source)
    expect(helper.sent_via(dmca)).to eq source
  end

  it 'handles missing notice sent_via' do
    dmca = build(:dmca, source: nil)
    expect(helper.sent_via(dmca)).to eq 'Unknown'
  end

  it 'correctly labels URL inputs' do
    court_order = build(:court_order)
    data_protection = build(:data_protection)
    defamation = build(:defamation)
    dmca = build(:dmca)
    law_enforcement = build(:law_enforcement_request)
    other = build(:other)
    private_information = build(:private_information)
    trademark = build(:trademark)

    expect(helper.label_for_url_input(:infringing_urls, court_order))
      .to eq 'Targeted URL'
    expect(helper.label_for_url_input(:infringing_urls, data_protection))
      .to eq 'URL mentioned in request'
    expect(helper.label_for_url_input(:infringing_urls, defamation))
      .to eq 'Allegedly Defamatory URL'
    expect(helper.label_for_url_input(:infringing_urls, dmca))
      .to eq 'Allegedly Infringing URL'
    expect(helper.label_for_url_input(:infringing_urls, law_enforcement))
      .to eq 'URL mentioned in request'
    expect(helper.label_for_url_input(:infringing_urls, other))
      .to eq 'Problematic URL'
    expect(helper.label_for_url_input(:infringing_urls, private_information))
      .to eq 'URL with private information'
    expect(helper.label_for_url_input(:infringing_urls, trademark))
      .to eq 'Allegedly Infringing URL'

    expect(helper.label_for_url_input(:copyrighted_urls, dmca))
      .to eq 'Original Work URL'
    expect(helper.label_for_url_input(:copyrighted_urls, law_enforcement))
      .to eq 'URL of original work'
    expect(helper.label_for_url_input(:copyrighted_urls, other))
      .to eq 'Original Work URL'
  end

  it 'handles bogus URL types' do
    dmca = build(:dmca)
    expect { helper.label_for_url_input(:party_time_urls, dmca) }
      .to raise_error(RuntimeError)
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
