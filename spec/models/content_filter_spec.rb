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

    it 'defaults to notice granularity' do
      filter = described_class.new(
        name: 'URL text',
        url_text: 'sensitive-name',
        actions: ['full_notice_version_only_researchers']
      )

      filter.valid?

      expect(filter.granularity).to eq('notice')
    end

    it 'does not apply URL-granularity filters as notice-wide actions' do
      filter = described_class.create!(
        name: 'URL text',
        url_text: 'sensitive-name',
        granularity: 'urls',
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
      expect(described_class.notice_has_action?(notice, :full_notice_version_only_researchers)).to be false
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

  describe '.match_set_for' do
    after do
      Current.reset
    end

    it 'evaluates all SQL-backed filters in one query and preserves their individual matches' do
      matching_filter = described_class.create!(
        name: 'Matching entity',
        query: '"entities"."name" = \'Stop\'',
        actions: ['full_notice_version_only_researchers']
      )
      described_class.create!(
        name: 'Other entity',
        query: '"entities"."name" = \'Keep going\'',
        actions: ['full_notice_version_only_lumen_team']
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.submitter.update!(name: 'Stop')

      expect(described_class)
        .to receive(:query_matches_for)
        .once
        .and_call_original

      match_set = described_class.match_set_for(notice)

      expect(match_set.notice_filters).to contain_exactly(matching_filter)
      expect(match_set.notice_has_action?(:full_notice_version_only_researchers)).to be true
      expect(match_set.notice_has_action?(:full_notice_version_only_lumen_team)).to be false
    end

    it 'reuses loaded filters and notice matches throughout one request context' do
      described_class.create!(
        name: 'Matching entity',
        query: '"entities"."name" = \'Stop\'',
        actions: ['full_notice_version_only_researchers']
      )
      first_notice = create(:dmca, role_names: %w[sender principal submitter])
      second_notice = create(:dmca, role_names: %w[sender principal submitter])
      first_notice.submitter.update!(name: 'Stop')
      second_notice.submitter.update!(name: 'Stop')
      Current.content_filter_context = Lumen::ContentFilters::Context.new

      expect(described_class).to receive(:all).once.and_call_original
      expect(described_class).to receive(:query_matches_for).twice.and_call_original

      3.times do
        expect(described_class.notice_has_action?(first_notice, :full_notice_version_only_researchers)).to be true
        expect(described_class.notice_filters_matching_notice(first_notice)).not_to be_empty
        expect(described_class.url_filters_matching_notice(first_notice)).to be_empty
      end
      described_class.notice_filters_matching_notice(second_notice)
    end
  end
end
