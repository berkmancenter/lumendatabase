require 'rails_helper'

describe Notices::SearchController do
  context "#index" do
    it "uses SearchesModels" do
      searcher = SearchesModels.new
      expect(SearchesModels).to receive(:new).and_return(searcher)

      get :index, { term: 'foo' }

      expect(response).to be_successful
    end
  end
end
