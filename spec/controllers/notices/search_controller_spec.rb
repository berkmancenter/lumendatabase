require 'rails_helper'

describe Notices::SearchController do
  describe 'search result caching' do
    it 'skips Elasticsearch and record hydration when the fragment is cached' do
      searcher = instance_double(
        Lumen::Search::Query,
        cache_key: 'cached-search',
        register: nil
      )
      allow(Lumen::Search::Query).to receive(:new).and_return(searcher)
      allow(controller).to receive(:perform_caching).and_return(true)
      allow(controller).to receive(:read_fragment)
        .with('cached-search')
        .and_return('<section class="search-results">cached</section>')

      expect(searcher).not_to receive(:search)

      get :index, params: { term: 'cached' }

      expect(response).to be_successful
      expect(assigns(:cached_search_results)).to include('cached')
    end
  end

  describe '#wrap_instances' do
    it 'loads only notices visible in search views' do
      visible_notice = create(:dmca)
      hidden_notice = build(:dmca, role_names: %w[submitter sender])
      hidden_notice.submitter.name = 'Google LLC'
      hidden_notice.sender.country_code = 'KR'
      hidden_notice.save!
      searchdata = [
        { _id: hidden_notice.id.to_s, _score: 2.0 },
        { _id: visible_notice.id.to_s, _score: 1.0 }
      ]
      controller.instance_variable_set(:@searchdata, searchdata)

      expect(controller.send(:wrap_instances)).to eq [visible_notice]
    end
  end

  context "#index" do
    it "uses Lumen::Search::Query" do
      searcher = Lumen::Search::Query.new
      expect(Lumen::Search::Query).to receive(:new).and_return(searcher)

      get :index, params: { term: 'foo' }

      expect(response).to be_successful
    end

    it 'does not store a legacy captcha response in the session' do
      searcher = instance_double(
        Lumen::Search::Query,
        cache_key: 'cached-search',
        register: nil
      )
      allow(searcher).to receive(:sort_by=)
      allow(Lumen::Search::Query).to receive(:new).and_return(searcher)
      allow(controller).to receive(:perform_caching).and_return(true)
      allow(controller).to receive(:read_fragment)
        .with('cached-search')
        .and_return('<section class="search-results">cached</section>')

      get :index,
          params: {
            term: 'example.com',
            sort_by: '',
            'g-recaptcha-response': 'secret-captcha-response' * 200
          }

      expect(response).to be_successful
      expect(session.to_hash.to_s).not_to include('secret-captcha-response')
    end
  end

  scenario 'deep pagination allowed with json', search: true do
    get :index, params: { page: 100, term: 'batman', format: :json }
    expect(response).to be_successful
  end

  scenario 'deep pagination not allowed with html', search: true do
    get :index, params: { page: 100, term: 'batman' }
    expect(response).to have_http_status :unauthorized
  end

  scenario 'shallow pagination allowed with html', search: true do
    get :index, params: { page: 10, term: 'batman' }
    expect(response).to be_successful
  end

  scenario 'per_page is capped for json', search: true do
    get :index, params: { per_page: 1_001, term: 'batman', format: :json }

    meta = JSON.parse(response.body).fetch('meta')
    expect(meta.fetch('per_page')).to eq 1_000
  end

  scenario 'deep pagination allowed for signed-in users', search: true do
    allow_any_instance_of(SearchController).to receive(:user_signed_in?)
                                           .and_return(true)
    get :index, params: { page: 100, term: 'batman' }
    expect(response).to be_successful
  end
end
