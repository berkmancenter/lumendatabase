require 'rails_helper'

describe TopicsController do
  context '#show' do
    it 'loads the topic by ID' do
      topic = double('Topic').as_null_object
      expect(Topic).to receive(:find).with('42').and_return(topic)

      get :show, id: 42

      expect(assigns(:topic)).to eq topic
      expect(response).to be_successful
      expect(response).to render_template(:show)
    end
  end

  context '#index as html' do
    it 'cannot be routed' do
      expect do
        get(:index, format: :html)
      end.to raise_error(ActionController::UrlGenerationError)
    end
  end

  context '#index as json' do
    it 'loads all topics' do
      build_list(:topic, 10)
      expect(Topic).to receive(:all)

      get :index, format: :json

      expect(response).to be_successful
    end

    it 'serializes topic data correctly' do
      parent_topic = create(:topic, name: 'Topic 1')
      child_topic = create(
        :topic, name: 'Topic 1 child', parent: parent_topic
      )

      get :index, format: :json

      json = JSON.parse(response.body)['topics']
      expect(json).to include(
        {"id"=>parent_topic.id, "name"=>parent_topic.name, "parent_id"=>nil}
      )

      expect(json).to include(
        {"id"=>child_topic.id, "name"=>child_topic.name,
         "parent_id"=>child_topic.parent_id}
      )
    end
  end
end
