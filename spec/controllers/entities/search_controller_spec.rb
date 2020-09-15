require 'rails_helper'

describe Entities::SearchController, type: :controller do
  context '#index' do
    it 'uses ElasticsearchQuery' do
      searcher = ElasticsearchQuery.new
      allow_any_instance_of(ElasticsearchQuery).to receive(:new).and_return(searcher)

      get :index, params: { term: 'foo', format: :json }
    end
  end
end
