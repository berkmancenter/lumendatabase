class TopicsController < ApplicationController
  def index
    render json: { topics: TopicSerializer.new(Topic.all) }
  end

  def show
    @topic = Topic.find(params[:id])
  end
end
