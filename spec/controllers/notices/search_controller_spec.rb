require 'rails_helper'

describe Notices::SearchController do
  context "#index" do
    it "uses Lumen::Search::Query" do
      searcher = Lumen::Search::Query.new
      expect(Lumen::Search::Query).to receive(:new).and_return(searcher)

      get :index, params: { term: 'foo' }

      expect(response).to be_successful
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
