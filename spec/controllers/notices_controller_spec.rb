require 'spec_helper'

describe NoticesController do
  context "#show" do
    it "successfully loads the notice by ID" do
      Notice.should_receive(:find).with('42')

      get :show, id: 42

      expect(response).to be_successful
    end

    it "renders the show template" do
      Notice.stub(:find)

      get :show, id: 1

      expect(response).to render_template(:show)
    end
  end

  context "#show as JSON" do
    it "serializes the notice metadata" do
      notice = create(:notice)

      get :show, id: notice.id, format: :json

      json = JSON.parse(response.body)["notice"]
      expect(json).to have_key(:id).with_value(notice.id)
      expect(json).to have_key(:title).with_value(notice.title)
      expect(json).to have_key(:body).with_value(notice.body)
      expect(json).to have_key(:date_received).with_value(notice.date_received)
    end

    it "includes the notice category names" do
      notice = create(:notice, :with_categories)

      get :show, id: notice.id, format: :json

      json = JSON.parse(response.body)["notice"]
      expect(json).to have_key(:categories)
      expect(json["categories"]).to match_array notice.categories.map(&:name)
    end
  end
end
