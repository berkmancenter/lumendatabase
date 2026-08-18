class Lumen::ContentFilters::MatchSet
  class << self
    def empty
      @empty ||= new(nil, []).freeze
    end
  end

  attr_reader :notice_filters, :url_filters

  def initialize(notice, content_filters)
    @notice = notice
    @content_filters = content_filters
    @query_matches = ContentFilter.query_matches_for(notice, content_filters)
    @notice_filters = matching_notice_filters.freeze
    @url_filters = matching_url_filters_for_notice.freeze
  end

  def notice_has_action?(action_id)
    notice_filters.any? { |content_filter| content_filter.has_action?(action_id) }
  end

  def matching_url_filters(url_instance)
    url_filters.select { |content_filter| content_filter.matches_url?(url_instance) }
  end

  private

  attr_reader :notice, :content_filters, :query_matches

  def matching_notice_filters
    content_filters.select do |content_filter|
      content_filter.notice_granularity? &&
        content_filter.matches_notice?(
          notice,
          query_match: query_matches.fetch(content_filter.id, false)
        )
    end
  end

  def matching_url_filters_for_notice
    content_filters.select do |content_filter|
      content_filter.urls_granularity? &&
        content_filter.matches_notice_query?(
          notice,
          query_match: query_matches.fetch(content_filter.id, false)
        )
    end
  end
end
