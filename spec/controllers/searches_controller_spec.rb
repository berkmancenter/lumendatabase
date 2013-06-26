require 'spec_helper'

describe SearchesController do
  context "#show" do
    it "uses NoticeSearcher" do
      searcher = NoticeSearcher.new
      NoticeSearcher.should_receive(:new).and_return(searcher)

      get :show

      expect(response).to be_successful
    end
  end
end
