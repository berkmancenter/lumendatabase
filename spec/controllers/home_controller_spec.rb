require 'spec_helper'

describe HomeController do
  context "#index" do
    it "finds recent notices" do
      Notice.should_receive(:recent)

      get :index

      expect(response).to be_successful
    end
  end
end
