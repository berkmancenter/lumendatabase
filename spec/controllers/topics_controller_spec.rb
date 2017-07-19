require 'rails_helper'

describe TopicsController do
  context "#show" do
    it "loads the topic by ID" do
      topic = double("Topic").as_null_object
      expect(Topic).to receive(:find).with('42').and_return(topic)

      get :show, id: 42

      expect(assigns(:topic)).to eq topic
      expect(response).to be_successful
      expect(response).to render_template(:show)
    end

    it "uses SearchesModels to find recent notices" do
      topic = double("Topic")
      allow(topic).to receive(:name).and_return('A topic name')
      allow(Topic).to receive(:find).and_return(topic)

      searcher = SearchesModels.new
      expect(SearchesModels).to receive(:new).with(
        { topic: topic.name }).and_return(searcher)

      get :show, id: 42
    end
  end

  context "#index as html" do
    it "cannot be routed" do
      expect do
        get(:index, format: :html)
      end.to raise_error(ActionController::UrlGenerationError)
    end
  end

  context "#index as json" do
    it "loads all topics" do
      topic_list = build_list(:topic, 10)
      expect(Topic).to receive(:all)

      get :index, format: :json

      expect(response).to be_successful
    end

    it "serializes topic data correctly" do
      parent_topic = create(:topic, name: 'Topic 1')
      child_topic = create(
        :topic, name: "Topic 1 child", parent: parent_topic
      )

      get :index, format: :json

      json = JSON.parse(response.body)["topics"]
      expect(json.first).to have_key('id').with_value(parent_topic.id)
      expect(json.first).to have_key('name').with_value(parent_topic.name)
      expect(json.first).to have_key('parent_id').with_value(nil)

      expect(json.last).to have_key('id').with_value(child_topic.id)
      expect(json.last).to have_key('name').with_value(child_topic.name)
      expect(json.last).to have_key('parent_id').with_value(child_topic.parent_id)
    end

  end
end
