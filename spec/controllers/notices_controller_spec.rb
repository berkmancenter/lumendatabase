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

  context "#create from JSON" do
    it "accepts JSON parameters" do
      post :create, notice: {
        title: 'title',
        works_attributes: [
          url: "http://example.com/the_work",
          description: "Work description",
          infringing_urls_attributes: [
            { url: "http://example.com/infringer_1" },
            { url: "http://example.com/infringer_2" }
          ]
        ],
        entity_notice_roles_attributes: [
          {
            name: 'principal',
            entity_attributes: { name: 'An entity' }
          }
        ]
      }, format: :json

      expect(response).to be_successful
      expect(response.headers['Location']).to eq notice_url(Notice.last)
    end

    it "returns a useful status code when a required parameter is missing" do
      post :create, notice: { title: "A title" }, format: :json

      expect(response).to be_unprocessable
    end

    it "returns errors about missing required parameters" do
      post :create, notice: { title: "A title" }, format: :json

      json = JSON.parse(response.body)
      expect(json).to have_key('works')
    end
  end

  context "#create from HTML" do
    it "redirects when saved successfully" do
      post_valid_notice(format: :html)

      expect(response).to redirect_to(:root)
    end

    it "renders the new template" do
      post_invalid_notice(format: :html)

      expect(response).to render_template(:new)
    end
  end

  private

  def post_valid_notice(options = {})
    notice = notice_double

    yield(notice) if block_given?

    post_notice(notice, options)
  end

  def post_invalid_notice(options = {})
    notice = notice_double
    notice.stub(:save).and_return(false)
    notice.stub(:errors).and_return(double(full_messages: []))

    yield(notice) if block_given?

    post_notice(notice, options)
  end

  def post_notice(notice, options = {})
    format = options.fetch(:format) { :json }

    Notice.stub(:new).and_return(notice)

    post :create, notice: { title: "A title" }, format: format
  end

  def notice_double
    double("Notice", save: true, notice_id: 1)
  end
end
