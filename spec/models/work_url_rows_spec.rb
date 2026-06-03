require 'rails_helper'

describe WorkUrlRows do
  describe '#visible_rows' do
    it 'redacts researcher-only matching URLs to domain rows and leaves other URLs full' do
      ContentFilter.create!(
        name: 'Sensitive URL',
        url_text: 'sensitive-name',
        granularity: 'urls',
        actions: ['full_notice_version_only_researchers']
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://example.com/sensitive-name/profile'),
          InfringingUrl.new(url: 'https://example.org/public')
        ]
      )
      notice.works = [work]
      notice.save!

      rows = described_class.new(
        work: work,
        type: 'infringing',
        notice: notice,
        user: nil
      ).visible_rows

      expect(rows.map(&:text)).to eq ['example.com - 1 URL', 'https://example.org/public']
      expect(rows.map(&:researchers_only)).to eq [true, nil]
    end

    it 'shows Lumen-team-only matching URLs as domain rows for non-admins' do
      ContentFilter.create!(
        name: 'Sensitive URL',
        url_text: 'sensitive-name',
        granularity: 'urls',
        actions: ['full_notice_version_only_lumen_team']
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://example.com/sensitive-name/profile'),
          InfringingUrl.new(url: 'https://example.org/public')
        ]
      )
      notice.works = [work]
      notice.save!

      rows = described_class.new(
        work: work,
        type: 'infringing',
        notice: notice,
        user: create(:user, :researcher)
      ).visible_rows

      expect(rows.map(&:text)).to eq ['example.com - 1 URL', 'https://example.org/public']
      expect(rows.map(&:researchers_only)).to eq [false, nil]
    end

    it 'shows admins full URLs for Lumen-team-only filtered content' do
      ContentFilter.create!(
        name: 'Sensitive URL',
        url_text: 'sensitive-name',
        granularity: 'urls',
        actions: ['full_notice_version_only_lumen_team']
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://example.com/sensitive-name/profile')
        ]
      )
      notice.works = [work]
      notice.save!

      rows = described_class.new(
        work: work,
        type: 'infringing',
        notice: notice,
        user: create(:user, :admin)
      ).visible_rows

      expect(rows.map(&:text)).to eq ['https://example.com/sensitive-name/profile']
      expect(rows.map(&:full)).to eq [true]
    end

    it 'redacts filter url_text from domain rows when it appears in the domain' do
      ContentFilter.create!(
        name: 'Sensitive Domain',
        url_text: 'sensitive',
        granularity: 'urls',
        actions: ['full_notice_version_only_lumen_team']
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://sensitive-domain.com/profile'),
          InfringingUrl.new(url: 'https://sensitive-domain.com/about')
        ]
      )
      notice.works = [work]
      notice.save!

      rows = described_class.new(
        work: work,
        type: 'infringing',
        notice: notice,
        user: create(:user, :researcher)
      ).visible_rows

      expect(rows.map(&:text)).to eq ['[REDACTED]-domain.com - 2 URLs']
    end

    it 'redacts filter url_text from researcher-only domain rows' do
      ContentFilter.create!(
        name: 'Sensitive Domain',
        url_text: 'sensitive',
        granularity: 'urls',
        actions: ['full_notice_version_only_researchers']
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://sensitive-domain.com/profile')
        ]
      )
      notice.works = [work]
      notice.save!

      rows = described_class.new(
        work: work,
        type: 'infringing',
        notice: notice,
        user: nil
      ).visible_rows

      expect(rows.map(&:text)).to eq ['[REDACTED]-domain.com - 1 URL']
    end

    it 'groups all URLs by domain when notice has full_notice_version_only_lumen_team flag for non-admins' do
      notice = create(:dmca,
        role_names: %w[sender principal submitter],
        full_notice_version_only_lumen_team: true
      )
      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://example.com/path'),
          InfringingUrl.new(url: 'https://other.com/path')
        ]
      )
      notice.works = [work]
      notice.save!

      rows = described_class.new(
        work: work,
        type: 'infringing',
        notice: notice,
        user: create(:user, :researcher)
      ).visible_rows

      expect(rows.map(&:text)).to eq ['example.com - 1 URL', 'other.com - 1 URL']
      expect(rows.map(&:researchers_only)).to eq [false, false]
    end

    it 'shows admins full URLs even when notice has full_notice_version_only_lumen_team flag' do
      notice = create(:dmca,
        role_names: %w[sender principal submitter],
        full_notice_version_only_lumen_team: true
      )
      work = Work.new(
        infringing_urls: [InfringingUrl.new(url: 'https://example.com/path')]
      )
      notice.works = [work]
      notice.save!

      rows = described_class.new(
        work: work,
        type: 'infringing',
        notice: notice,
        user: create(:user, :admin)
      ).visible_rows

      expect(rows.map(&:text)).to eq ['https://example.com/path']
      expect(rows.map(&:full)).to eq [true]
    end

    it 'groups all URLs by domain when a notice-granularity lumen_team filter matches, redacting url_text in domain' do
      ContentFilter.create!(
        name: 'Sensitive Notice',
        url_text: 'secret',
        granularity: 'notice',
        actions: ['full_notice_version_only_lumen_team']
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://secret-corp.com/page'),
          InfringingUrl.new(url: 'https://other.com/page')
        ]
      )
      notice.works = [work]
      notice.save!

      rows = described_class.new(
        work: work,
        type: 'infringing',
        notice: notice,
        user: create(:user, :researcher)
      ).visible_rows

      expect(rows.map(&:text)).to eq ['[REDACTED]-corp.com - 1 URL', 'other.com - 1 URL']
    end

    it 'groups all URLs by domain when notice has full_notice_version_only_researchers flag for non-researchers' do
      notice = create(:dmca,
        role_names: %w[sender principal submitter],
        full_notice_version_only_researchers: true
      )
      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://example.com/path')
        ]
      )
      notice.works = [work]
      notice.save!

      rows = described_class.new(
        work: work,
        type: 'infringing',
        notice: notice,
        user: nil
      ).visible_rows

      expect(rows.map(&:text)).to eq ['example.com - 1 URL']
      expect(rows.map(&:researchers_only)).to eq [true]
    end

    it 'loads matching notice filters once for all URLs' do
      filter = ContentFilter.create!(
        name: 'Sensitive URL',
        url_text: 'sensitive-name',
        granularity: 'urls',
        actions: ['full_notice_version_only_lumen_team']
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://example.com/sensitive-name/profile'),
          InfringingUrl.new(url: 'https://example.org/public')
        ]
      )
      notice.works = [work]
      notice.save!

      expect(ContentFilter)
        .to receive(:url_filters_matching_notice)
        .once
        .with(notice)
        .and_return([filter])

      described_class.new(
        work: work,
        type: 'infringing',
        notice: notice,
        user: create(:user, :researcher)
      ).visible_rows
    end
  end

  describe '#rows' do
    it 'normalizes URL objects to a common view row shape' do
      url = InfringingUrl.new(url: 'https://example.com/path')
      url.only_fqdn = true
      work = Work.new(infringing_urls: [url])

      url_row = described_class.new(work: work, type: 'infringing').rows.first

      expect(url_row.text).to eq 'https://example.com/path'
      expect(url_row.researchers_only).to be true
    end
  end

  describe '.normalize_collection' do
    it 'normalizes hash rows to a common view row shape' do
      row = described_class.normalize_collection(
        [{ text: 'example.org - 2 URLs', researchers_only: false }]
      ).first

      expect(row.text).to eq 'example.org - 2 URLs'
      expect(row.researchers_only).to be false
    end
  end

  describe '.enterprise_rows' do
    it 'reveals enterprise-matching URLs and groups the rest by domain' do
      enterprise_account = create(:enterprise_account)
      create(:enterprise_domain, enterprise_account: enterprise_account, domain: 'business.example', verified: true)
      user = create(:user, :enterprise, enterprise_account: enterprise_account)
      notice = create(:dmca, role_names: %w[sender principal submitter])
      urls = [
        InfringingUrl.new(url: 'https://business.example/path'),
        InfringingUrl.new(url: 'https://other.example/a'),
        InfringingUrl.new(url: 'https://other.example/b')
      ]

      rows = described_class.enterprise_rows(
        urls,
        enterprise_access: EnterpriseNoticeAccess.new(user, notice)
      )

      expect(rows.map(&:text)).to eq ['https://business.example/path', 'other.example - 2 URLs']
      expect(rows.map(&:full)).to eq [true, false]
      expect(rows.map(&:fqdn)).to eq [nil, 'other.example']
      expect(rows.map(&:count)).to eq [nil, 2]
    end
  end
end
