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
    it "finds and serializes the notice" do
      notice = create(:notice_with_notice_file, content: "Some content")

      get :show, id: notice.id, format: :json

      json = JSON.parse(response.body)["notice"]
      expect(json).to have_key(:id).with_value(notice.id)
      expect(json).to have_key(:title).with_value(notice.title)
      expect(json).to have_key(:body).with_value(notice.body)
      expect(json).to have_key(:date_sent).with_value(notice.date_sent)
      expect(json).to have_key(:notice_file_content).with_value("Some content")
    end
  end
end
