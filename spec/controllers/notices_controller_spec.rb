require 'spec_helper'

describe NoticesController do
  context "#show" do
    it "successfully loads the notice by ID" do
      Notice.should_receive(:find).with('42')

      get :show, id: 42

      expect(response).to be_successful
    end
  end
end
