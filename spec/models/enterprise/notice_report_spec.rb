require 'rails_helper'

describe Lumen::Enterprise::NoticeReport, type: :model do
  let(:enterprise_account) { create(:enterprise_account) }
  let(:starts_at) { 1.day.ago }
  let(:ends_at) { Time.current }
  let(:search_arguments) { [] }
  let(:elasticsearch_client) { Notice.__elasticsearch__.client }

  before do
    create(
      :enterprise_domain,
      enterprise_account: enterprise_account,
      domain: 'business.example',
      verified: true
    )
  end

  describe '#notices' do
    it 'uses Elasticsearch candidates and preserves NoticeAccess as the final gate' do
      matching_notice = create_notice_with_url('https://business.example/path')
      false_positive = create_notice_with_url('https://unrelated.example/path')
      hidden_notice = create_notice_with_url('https://business.example/hidden')
      hidden_notice.update!(hidden: true)
      stub_notice_search(false_positive.id, hidden_notice.id, matching_notice.id)

      expect(Notice).not_to receive(:visible)

      notices = described_class
                .new(enterprise_account, starts_at: starts_at, ends_at: ends_at)
                .notices

      expect(notices).to eq([matching_notice])
      expect(search_arguments.first[:body][:query][:bool][:filter]).to include(
        { term: { spam: false } },
        { term: { hidden: false } },
        { term: { published: true } },
        { term: { rescinded: false } },
        { range: { created_at: { gte: starts_at.iso8601, lte: ends_at.iso8601 } } }
      )
      expect(domain_filter(search_arguments.first)[:bool][:should]).to eq(
        [
          {
            match_phrase: {
              'works.infringing_urls.url': 'business.example'
            }
          }
        ]
      )
    end

    it 'returns an empty report without searching for inactive accounts' do
      enterprise_account.update!(plan: 'inactive')

      expect(elasticsearch_client).not_to receive(:search)

      notices = described_class
                .new(enterprise_account, starts_at: starts_at, ends_at: ends_at)
                .notices

      expect(notices).to eq([])
    end

    it 'continues searching with search_after until Elasticsearch has no full batch' do
      stub_const('Lumen::Enterprise::NoticeReport::SEARCH_BATCH_SIZE', 2)
      notices = create_list(:dmca, 3).each_with_index do |notice, index|
        notice.works = [
          Work.new(
            infringing_urls: [
              InfringingUrl.new(url: "https://business.example/#{index}")
            ],
            copyrighted_urls: []
          )
        ]
        notice.save!
      end
      stub_notice_search_pages(
        notice_search_hits(notices[0].id, notices[1].id),
        notice_search_hits(notices[2].id)
      )

      result = described_class
               .new(enterprise_account, starts_at: starts_at, ends_at: ends_at)
               .notices

      expect(result).to eq(notices)
      expect(search_arguments.second[:body][:search_after]).to eq(
        notice_search_hit(notices[1].id)['sort']
      )
    end
  end

  describe '.recent' do
    it 'returns newest matching notices up to the requested limit' do
      notices = 3.times.map do |index|
        create_notice_with_url("https://business.example/#{index}")
      end
      stub_notice_search(*notices.map(&:id))

      expect(described_class.recent(enterprise_account, limit: 2)).to eq(
        notices.first(2)
      )
    end
  end

  def create_notice_with_url(url)
    create(
      :dmca,
      works: [
        Work.new(
          infringing_urls: [
            InfringingUrl.new(url: url)
          ],
          copyrighted_urls: []
        )
      ]
    )
  end

  def stub_notice_search(*notice_ids)
    stub_notice_search_pages(notice_search_hits(*notice_ids))
  end

  def stub_notice_search_pages(*hit_pages)
    allow(elasticsearch_client).to receive(:search) do |arguments|
      search_arguments << arguments

      {
        'hits' => {
          'hits' => hit_pages.shift || []
        }
      }
    end
  end

  def notice_search_hits(*notice_ids)
    notice_ids.map { |notice_id| notice_search_hit(notice_id) }
  end

  def notice_search_hit(notice_id)
    {
      '_source' => { 'id' => notice_id },
      '_id' => notice_id.to_s,
      'sort' => [Time.current.iso8601, notice_id.to_s]
    }
  end

  def domain_filter(search_argument)
    search_argument[:body][:query][:bool][:filter].find do |filter|
      filter[:bool]&.key?(:should)
    end
  end
end
