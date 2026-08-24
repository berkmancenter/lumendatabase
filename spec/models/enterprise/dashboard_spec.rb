require 'rails_helper'

describe Lumen::Enterprise::Dashboard, type: :model do
  let(:enterprise_account) { create(:enterprise_account) }
  let(:now) { Time.zone.parse('2026-08-23 12:00:00') }
  let(:elasticsearch_client) { Notice.__elasticsearch__.client }

  before do
    create(
      :enterprise_domain,
      enterprise_account: enterprise_account,
      domain: 'business.example',
      verified: true
    )
  end

  it 'builds the thirty-day summary from one aggregation query' do
    allow(elasticsearch_client).to receive(:search).and_return(
      {
        'hits' => { 'hits' => [] },
        'aggregations' => {
          'daily_notices' => {
            'buckets' => [
              { 'key_as_string' => '2026-08-16', 'doc_count' => 8 },
              { 'key_as_string' => '2026-08-20', 'doc_count' => 4 }
            ]
          },
          'notice_types' => {
            'buckets' => [
              { 'key' => 'DMCA', 'doc_count' => 9 },
              { 'key' => 'Trademark', 'doc_count' => 3 }
            ]
          }
        }
      }
    )

    dashboard = described_class.new(enterprise_account, now: now)

    expect(dashboard.total_notices).to eq(12)
    expect(dashboard.notices_last_seven_days).to eq(4)
    expect(dashboard.daily_activity.size).to eq(30)
    expect(dashboard.daily_activity[Date.new(2026, 8, 20)]).to eq(4)
    expect(dashboard.notice_types).to eq('DMCA' => 9, 'Trademark' => 3)

    expect(elasticsearch_client).to have_received(:search).once do |arguments|
      expect(arguments[:body]).to include(
        _source: false,
        size: described_class::RECENT_CANDIDATE_LIMIT,
        track_total_hits: false,
        sort: [
          { created_at: { order: 'desc' } },
          { id: { order: 'desc' } }
        ]
      )

      filters = arguments.dig(:body, :query, :bool, :filter)
      expect(filters).to include(
        { term: { spam: false } },
        { term: { hidden: false } },
        { term: { published: true } },
        { term: { rescinded: false } }
      )
      expect(filters).to include(
        {
          bool: {
            should: [
              { match_phrase: { 'works.infringing_urls.url': 'business.example' } }
            ],
            minimum_should_match: 1
          }
        }
      )
    end
  end

  it 'loads recent notices from the same bounded summary query' do
    notice = create(
      :dmca,
      role_names: %w[recipient submitter],
      created_at: 1.day.ago(now),
      works: [
        Work.new(
          infringing_urls: [
            InfringingUrl.new(url: 'https://business.example/reported')
          ],
          copyrighted_urls: []
        )
      ]
    )

    allow(elasticsearch_client).to receive(:search).and_return(
      {
        'hits' => {
          'hits' => [
            { '_id' => notice.id.to_s }
          ]
        },
        'aggregations' => {
          'daily_notices' => { 'buckets' => [] },
          'notice_types' => { 'buckets' => [] }
        }
      }
    )

    expect(Lumen::Enterprise::NoticeReport).not_to receive(:recent)

    dashboard = described_class.new(enterprise_account, now: now)

    expect(dashboard.recent_notices).to eq([notice])
    expect(dashboard.total_notices).to eq(0)
    expect(elasticsearch_client).to have_received(:search).once
  end

  it 'briefly caches the summary query for repeated dashboard requests' do
    allow(Rails).to receive(:cache).and_return(
      ActiveSupport::Cache::MemoryStore.new
    )
    allow(elasticsearch_client).to receive(:search).and_return(
      {
        'hits' => { 'hits' => [] },
        'aggregations' => {
          'daily_notices' => {
            'buckets' => [
              { 'key_as_string' => '2026-08-20', 'doc_count' => 4 }
            ]
          },
          'notice_types' => { 'buckets' => [] }
        }
      }
    )

    2.times do
      expect(described_class.new(enterprise_account, now: now).total_notices)
        .to eq(4)
    end

    expect(elasticsearch_client).to have_received(:search).once
  end

  it 'does not query Elasticsearch without verified domains' do
    enterprise_account.enterprise_domains.destroy_all
    dashboard = described_class.new(enterprise_account, now: now)

    expect(elasticsearch_client).not_to receive(:search)
    expect(Lumen::Enterprise::NoticeReport).not_to receive(:recent)

    expect(dashboard.total_notices).to eq(0)
    expect(dashboard.daily_activity.values).to all(eq(0))
    expect(dashboard.recent_notices).to eq([])
  end

  it 'uses exact enterprise access rules when counting matching URLs' do
    notice = build(
      :dmca,
      works: [
        Work.new(
          infringing_urls: [
            InfringingUrl.new(url: 'https://business.example/one'),
            InfringingUrl.new(url: 'https://unrelated.example/two')
          ],
          copyrighted_urls: []
        )
      ]
    )

    dashboard = described_class.new(enterprise_account, now: now)

    expect(dashboard.matching_url_count(notice)).to eq(1)
  end
end
