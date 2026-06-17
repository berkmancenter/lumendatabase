require 'spec_helper'

describe NoticeSerializer do
  it_behaves_like 'a serialized notice with base metadata'

  it 'includes works' do
    with_a_serialized_notice do |notice, json|
      expect(json[:works].map { |w| w['description'] }).to eq(notice.works.map(&:description))
    end
  end

  %i|infringing_urls copyrighted_urls|.each do |url_relation|
    it "includes #{url_relation}" do
      allow_any_instance_of(Lumen::Ability).to receive(:can?).and_return(true)
      allow_any_instance_of(Current).to receive(:user).and_return(create(:user, :admin))

      with_a_serialized_notice do |notice, json|
        relation_json = json[:works].first[url_relation.to_s].map{ |u| u['url'] }
        expect(relation_json).to eq(
          notice.works.first.send(url_relation).map(&:url)
        )
        expect(relation_json.length).not_to eq 0
      end
    end
  end

  it 'includes a score attribute when the model responds to _score' do
    notice = build_notice
    allow(notice).to receive(:_score).and_return(2)
    serializer = NoticeSerializer.new(notice)
    score = serializer.as_json[:score]

    expect(score).to eq 2
  end

  it 'reveals matching URLs for enterprise users while API access is enabled' do
    stub_const('NoticeSerializer::ENTERPRISE_API_ACCESS_ENABLED', true)

    enterprise_account = create(:enterprise_account)
    create(:enterprise_domain, enterprise_account: enterprise_account, domain: 'business.example', verified: true)
    Current.user = create(:user, :enterprise, enterprise_account: enterprise_account)

    notice = build(
      :dmca,
      works: [
        Work.new(
          infringing_urls: [
            InfringingUrl.new(url: 'https://business.example/path'),
            InfringingUrl.new(url: 'https://other.example/path')
          ],
          copyrighted_urls: [
            CopyrightedUrl.new(url: 'https://business.example/original')
          ]
        )
      ]
    )

    work_json = described_class.new(notice).as_json[:works].first

    expect(work_json['infringing_urls']).to eq [
      { 'url' => 'https://business.example/path' },
      { 'fqdn' => 'other.example', 'count' => 1 }
    ]
    expect(work_json['copyrighted_urls']).to eq [
      { 'url' => 'https://business.example/original' }
    ]
  ensure
    Current.user = nil
  end

  it 'does not reveal matching URLs for enterprise users while API access is disabled' do
    stub_const('NoticeSerializer::ENTERPRISE_API_ACCESS_ENABLED', false)

    enterprise_account = create(:enterprise_account)
    create(:enterprise_domain, enterprise_account: enterprise_account, domain: 'business.example', verified: true)
    Current.user = create(:user, :enterprise, enterprise_account: enterprise_account)

    notice = build(
      :dmca,
      works: [
        Work.new(
          infringing_urls: [
            InfringingUrl.new(url: 'https://business.example/path'),
            InfringingUrl.new(url: 'https://other.example/path')
          ],
          copyrighted_urls: [
            CopyrightedUrl.new(url: 'https://business.example/original')
          ]
        )
      ]
    )

    work_json = described_class.new(notice).as_json[:works].first

    expect(work_json['infringing_urls']).to contain_exactly(
      { 'fqdn' => 'business.example', 'count' => 1 },
      { 'fqdn' => 'other.example', 'count' => 1 }
    )
    expect(work_json['copyrighted_urls']).to eq [
      { 'fqdn' => 'business.example', 'count' => 1 }
    ]
  ensure
    Current.user = nil
  end

  it 'does not reveal matching URLs in the API for inactive enterprise accounts' do
    enterprise_account = create(:enterprise_account, :inactive)
    create(:enterprise_domain, enterprise_account: enterprise_account, domain: 'business.example', verified: true)
    Current.user = create(:user, :enterprise, enterprise_account: enterprise_account)

    notice = build(
      :dmca,
      works: [
        Work.new(
          infringing_urls: [
            InfringingUrl.new(url: 'https://business.example/path')
          ],
          copyrighted_urls: [
            CopyrightedUrl.new(url: 'https://business.example/original')
          ]
        )
      ]
    )

    work_json = described_class.new(notice).as_json[:works].first

    expect(work_json['infringing_urls']).to eq [
      { 'fqdn' => 'business.example', 'count' => 1 }
    ]
    expect(work_json['copyrighted_urls']).to eq [
      { 'fqdn' => 'business.example', 'count' => 1 }
    ]
  ensure
    Current.user = nil
  end

  it 'does not reveal full URLs to researchers for Lumen-team-only notices' do
    Current.user = create(:user, :researcher, limit_notice_api_response: false)
    notice = build(
      :dmca,
      full_notice_version_only_lumen_team: true,
      works: [
        Work.new(
          infringing_urls: [
            InfringingUrl.new(url: 'https://restricted.example/path')
          ],
          copyrighted_urls: [
            CopyrightedUrl.new(url: 'https://restricted.example/original')
          ]
        )
      ]
    )

    work_json = described_class.new(notice).as_json[:works].first

    expect(work_json['infringing_urls']).to eq [
      { 'fqdn' => 'restricted.example', 'count' => 1 }
    ]
    expect(work_json['copyrighted_urls']).to eq [
      { 'fqdn' => 'restricted.example', 'count' => 1 }
    ]
  ensure
    Current.user = nil
  end

  describe '.serialize_url_rows' do
    it 'maps full URL rows to {url:} and grouped rows to {fqdn:, count:}' do
      rows = [
        Lumen::WorkUrlRows::Row.new(text: 'https://example.com/path', url: 'https://example.com/path', full: true, researchers_only: false),
        Lumen::WorkUrlRows::Row.new(text: 'other.com - 2 URLs', fqdn: 'other.com', count: 2, full: false, researchers_only: true)
      ]

      expect(described_class.serialize_url_rows(rows)).to eq [
        { url: 'https://example.com/path' },
        { fqdn: 'other.com', count: 2 }
      ]
    end
  end

  context 'with content-filtered URLs in a full API response' do
    let(:researcher) { create(:user, :researcher, limit_notice_api_response: false) }
    let(:admin) { create(:user, :admin) }
    let(:notice) do
      n = create(:dmca, role_names: %w[sender principal submitter])
      n.works = [Work.new(infringing_urls: [
        InfringingUrl.new(url: 'https://sensitive-name.example.com/profile'),
        InfringingUrl.new(url: 'https://example.org/public')
      ])]
      n.save!
      n
    end

    before do
      ContentFilter.delete_all
      ContentFilter.create!(
        name: 'Sensitive URL',
        url_text: 'sensitive-name',
        granularity: 'urls',
        actions: ['full_notice_version_only_lumen_team']
      )
      allow_any_instance_of(Lumen::Ability).to receive(:can?).with(:view_full_version_api, anything).and_return(true)
      allow_any_instance_of(Lumen::Ability).to receive(:can?).with(:view_enterprise_version, anything).and_return(false)
    end

    it 'groups Lumen-team-only filtered URLs as domain counts for researchers' do
      allow_any_instance_of(Current).to receive(:user).and_return(researcher)

      work_json = described_class.new(notice).as_json[:works].first

      expect(work_json['infringing_urls']).to eq [
        { 'fqdn' => '[REDACTED].example.com', 'count' => 1 },
        { 'url' => 'https://example.org/public' }
      ]
    end

    it 'shows admins full URLs for Lumen-team-only filtered content' do
      allow_any_instance_of(Current).to receive(:user).and_return(admin)

      work_json = described_class.new(notice).as_json[:works].first

      expect(work_json['infringing_urls']).to eq [
        { 'url' => 'https://sensitive-name.example.com/profile' },
        { 'url' => 'https://example.org/public' }
      ]
    end
  end
end
