require 'spec_helper'

describe EnterpriseNoticeAccess do
  let(:enterprise_account) { create(:enterprise_account) }
  let(:user) { create(:user, :enterprise, enterprise_account: enterprise_account) }

  before do
    create(:enterprise_domain, enterprise_account: enterprise_account, domain: 'business.example', verified: true)
  end

  describe '#allowed?' do
    it 'allows an enterprise user when an unrestricted notice has a matching infringing URL' do
      notice = build_notice_with_urls(
        infringing_urls: [
          'https://business.example/path',
          'https://unrelated.example/path'
        ]
      )

      expect(described_class.new(user, notice)).to be_allowed
    end

    it 'does not allow access to researchers-only notices' do
      notice = build_notice_with_urls(
        infringing_urls: ['https://business.example/path'],
        full_notice_version_only_researchers: true
      )

      expect(described_class.new(user, notice)).not_to be_allowed
    end

    it 'does not allow access to Lumen-team-only notices' do
      notice = build_notice_with_urls(infringing_urls: ['https://business.example/path'])
      ContentFilter.create!(
        name: 'Business example filter',
        url_text: 'business.example',
        actions: ['full_notice_version_only_lumen_team']
      )

      expect(described_class.new(user, notice)).not_to be_allowed
    end

    it 'does not allow access to notice-level admins-only notices' do
      notice = build_notice_with_urls(
        infringing_urls: ['https://business.example/path'],
        full_notice_version_only_lumen_team: true
      )

      expect(described_class.new(user, notice)).not_to be_allowed
    end

    it 'does not allow access through unverified domains' do
      enterprise_account.enterprise_domains.update_all(verified: false)
      notice = build_notice_with_urls(infringing_urls: ['https://business.example/path'])

      expect(described_class.new(user, notice)).not_to be_allowed
    end

    it 'does not allow access when the account is not on the pro plan' do
      enterprise_account.update!(plan: 'inactive')
      notice = build_notice_with_urls(infringing_urls: ['https://business.example/path'])

      expect(described_class.new(user, notice)).not_to be_allowed
    end
  end

  describe '#url_rows' do
    it 'reveals matching URLs and keeps other URLs aggregated' do
      notice = build_notice_with_urls(
        infringing_urls: [
          'https://business.example/path',
          'https://other.example/a',
          'https://other.example/b'
        ]
      )
      access = described_class.new(user, notice)
      rows = access.url_rows(notice.works.first.infringing_urls)

      expect(rows.map(&:text)).to eq ['https://business.example/path', 'other.example - 2 URLs']
      expect(rows.map(&:url)).to eq ['https://business.example/path', nil]
      expect(rows.map(&:full)).to eq [true, false]
      expect(rows.map(&:researchers_only)).to eq [false, false]
      expect(rows.map(&:fqdn)).to eq [nil, 'other.example']
      expect(rows.map(&:count)).to eq [nil, 2]
    end

    it 'reveals matching copyrighted URLs' do
      notice = build_notice_with_urls(
        copyrighted_urls: ['https://business.example/original']
      )
      access = described_class.new(user, notice)
      rows = access.url_rows(notice.works.first.copyrighted_urls)

      expect(rows.map(&:text)).to eq ['https://business.example/original']
      expect(rows.map(&:url)).to eq ['https://business.example/original']
      expect(rows.map(&:full)).to eq [true]
      expect(rows.map(&:researchers_only)).to eq [false]
    end

    it 'reveals the redacted URL value rather than url_original' do
      notice = build(
        :dmca,
        works: [
          Work.new(
            infringing_urls: [
              InfringingUrl.new(
                url: 'https://business.example/[REDACTED]',
                url_original: 'https://business.example/private'
              )
            ],
            copyrighted_urls: []
          )
        ]
      )
      access = described_class.new(user, notice)
      rows = access.url_rows(notice.works.first.infringing_urls)

      expect(rows.map(&:text)).to eq ['https://business.example/[REDACTED]']
      expect(rows.map(&:url)).to eq ['https://business.example/[REDACTED]']
      expect(rows.map(&:full)).to eq [true]
      expect(rows.map(&:researchers_only)).to eq [false]
    end

    it 'lists filtered special-domain URL values when they match verified domains' do
      notice = build_notice_with_urls(
        infringing_urls: ['https://business.example/researchers-only']
      )
      SpecialDomain.create!(
        domain_name: '%business.example%',
        why_special: ['full_urls_only_for_researchers']
      )
      access = described_class.new(user, notice)
      rows = access.url_rows(notice.works.first.infringing_urls_public)

      expect(rows.map(&:text)).to eq ['business.example']
      expect(rows.map(&:url)).to eq ['business.example']
      expect(rows.map(&:full)).to eq [true]
      expect(rows.map(&:researchers_only)).to eq [false]
    end
  end

  describe '#serialized_urls' do
    it 'serializes URL rows for API responses' do
      notice = build_notice_with_urls(
        infringing_urls: [
          'https://business.example/path',
          'https://other.example/path'
        ]
      )
      access = described_class.new(user, notice)

      expect(access.serialized_urls(notice.works.first.infringing_urls)).to eq [
        { url: 'https://business.example/path' },
        { fqdn: 'other.example', count: 1 }
      ]
    end
  end

  def build_notice_with_urls(infringing_urls: [], copyrighted_urls: [], **attributes)
    build(
      :dmca,
      attributes.merge(
        works: [
          Work.new(
            infringing_urls: infringing_urls.map { |url| InfringingUrl.new(url: url) },
            copyrighted_urls: copyrighted_urls.map { |url| CopyrightedUrl.new(url: url) }
          )
        ]
      )
    )
  end
end
