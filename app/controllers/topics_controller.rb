class TopicsController < ApplicationController

  def index
    render json: Topic.all
  end

  def show
    @topic = Topic.find(params[:id])
    searcher = topic_notice_searcher(@topic.name)

    searcher.search
    @notices = searcher.instances
  end

  private

  def topic_notice_searcher(topic_name)
    searcher = SearchesModels.new({ topic: topic_name })
    searcher.register TermSearch.new(:topic, :topic_facet)
    searcher.sort_by = :date_received, :desc
    searcher
  end

end
