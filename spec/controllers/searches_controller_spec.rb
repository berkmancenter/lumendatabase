require 'spec_helper'

describe SearchesController do
  context "#show" do
    it "executes a search based on query, and assigns results" do
      results = double("Results")
      Notice.should_receive(:search).and_return(results)

      get :show

      expect(response).to be_successful
      expect(assigns(:results)).to eq results
    end
  end
end
