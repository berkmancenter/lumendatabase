class TopicsController < ApplicationController
  def index
    render json: { topics: TopicSerializer.new(Topic.all) }
  end

  def show
    @topic = Topic.find(params[:id])
    LumenLogger.log_metrics('VIEWED_TOPIC', topic: @topic.name, topic_id: @topic.id)
  end
end
