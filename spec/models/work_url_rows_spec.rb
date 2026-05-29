require 'rails_helper'

describe WorkUrlRows do
  describe '#content_filter_rows' do
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
      ).content_filter_rows

      expect(rows.map(&:text)).to eq ['example.com - 1 URL', 'https://example.org/public']
      expect(rows.map(&:only_fqdn)).to eq [true, nil]
    end

    it 'hides Lumen-team-only matching URLs and leaves other URLs full' do
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
      ).content_filter_rows

      expect(rows.map(&:text)).to eq ['https://example.org/public']
    end

    it 'shows Lumen-team-only matching URLs to admins' do
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
      ).content_filter_rows

      expect(rows.map(&:text)).to eq ['https://example.com/sensitive-name/profile']
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
      ).content_filter_rows
    end
  end

  describe '#rows' do
    it 'normalizes URL objects to a common view row shape' do
      url = InfringingUrl.new(url: 'https://example.com/path')
      url.only_fqdn = true
      work = Work.new(infringing_urls: [url])

      url_row = described_class.new(work: work, type: 'infringing').rows.first

      expect(url_row.text).to eq 'https://example.com/path'
      expect(url_row.only_fqdn).to be true
    end
  end

  describe '.normalize_collection' do
    it 'normalizes hash rows to a common view row shape' do
      row = described_class.normalize_collection(
        [{ text: 'example.org - 2 URLs', only_fqdn: false }]
      ).first

      expect(row.text).to eq 'example.org - 2 URLs'
      expect(row.only_fqdn).to be false
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
