class MediaMentions::SearchController < SearchController
  URL_ROOT = 'media_mention'.freeze
  SEARCHED_MODEL = MediaMention

  private

  def set_model_specific_variables
    @model_class = MediaMention
    @search_index_path = media_mentions_search_index_path
    @searchable_fields = MediaMention::SEARCHABLE_FIELDS
    @filterable_fields = MediaMention::FILTERABLE_FIELDS
    @ordering_options = MediaMention::ORDERING_OPTIONS
    @url_root = URL_ROOT
    @search_all_placeholder = 'Search all research and media mentions...'
    @facet_search_index_path = facet_media_mentions_search_index_path
    @skip_captcha = true
  end

  def item_searcher
    ElasticsearchQuery.new(params, MediaMention).tap do |searcher|
      @searchable_fields.each do |searched_field|
        searcher.register searched_field
      end

      @filterable_fields.each do |filtered_field|
        searcher.register filtered_field
      end

      searcher.sort_by = sort_by(params[:sort_by])
    end
  end

  # We don't need to limit access to research papers
  def restrict_deep_pagination; end
end
