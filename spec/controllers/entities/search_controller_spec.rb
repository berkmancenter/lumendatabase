require 'spec_helper'

describe Entities::SearchController do
  context "#index" do
    it "uses SearchesModels" do
      searcher = SearchesModels.new
      SearchesModels.should_receive(:new).and_return(searcher)

      get :index, { term: 'foo' }, format: :json
    end
  end
end
