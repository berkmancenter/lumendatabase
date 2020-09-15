# Postprocesses elasticsearch results for display on TopicsController#show.
module TopicsHelper
  NoticeMetadata = Struct.new(:title, :id)

  # Pulls notice name and id from elasticsearch results (which is all we need
  # in order to render the page). This lets us avoid potentially expensive AR
  # instantiations.
  def recent_notice_metadata
    searcher = topic_notice_searcher
    results = searcher.search
    results.map { |r| NoticeMetadata.new(r._source.title, r._source.id) }
  end

  private

  # Searches for notices relevant to the topic. Limits to 10 results maximum
  # as this information will be populating a recent notice sidebar and
  # therefore does not need to be comprehensive.
  def topic_notice_searcher
    searcher = ElasticsearchQuery.new(topic: @topic.name, size: 10)
    searcher.register TermSearch.new(:topic, :topic_facet)
    searcher.sort_by = :date_received, :desc
    searcher
  end
end
