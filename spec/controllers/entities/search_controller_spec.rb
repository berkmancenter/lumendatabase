require 'rails_helper'

describe Entities::SearchController, type: :controller do
  context '#index' do
    it 'uses Lumen::Search::Query' do
      searcher = Lumen::Search::Query.new
      allow_any_instance_of(Lumen::Search::Query).to receive(:new).and_return(searcher)

      get :index, params: { term: 'foo', format: :json }
    end
  end
end
