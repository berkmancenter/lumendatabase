require 'rails_helper'

describe ContentFilter do
  describe '#matches_notice?' do
    it 'matches notices by case-insensitive URL text' do
      filter = described_class.new(
        name: 'URL text',
        url_text: 'sensitive-name',
        actions: ['full_notice_version_only_researchers']
      )
      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://example.com/Sensitive-Name/profile')
        ]
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save!

      expect(filter.matches_notice?(notice)).to be true
    end

    it 'matches redacted URLs using original URL text' do
      filter = described_class.new(
        name: 'URL text',
        url_text: 'sensitive-name',
        actions: ['full_notice_version_only_researchers']
      )
      url = InfringingUrl.new(url: Lumen::REDACTION_MASK)
      url.url_original = 'https://example.com/sensitive-name/profile'
      work = Work.new(infringing_urls: [url])
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save!

      expect(filter.matches_notice?(notice)).to be true
    end

    it 'requires all configured criteria to match' do
      filter = described_class.new(
        name: 'URL text and query',
        query: '"entities"."name" = \'Stop\' ',
        url_text: 'sensitive-name',
        actions: ['full_notice_version_only_researchers']
      )
      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://example.com/sensitive-name/profile')
        ]
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save!

      expect(filter.matches_notice?(notice)).to be false
    end
  end

  describe 'validations' do
    it 'allows a filter with URL text and no SQL query' do
      filter = described_class.new(
        name: 'URL text',
        url_text: 'sensitive-name',
        actions: ['full_notice_version_only_researchers']
      )

      expect(filter).to be_valid
    end

    it 'requires query or URL text' do
      filter = described_class.new(
        name: 'Empty',
        actions: ['full_notice_version_only_researchers']
      )

      expect(filter).not_to be_valid
    end
  end
end
