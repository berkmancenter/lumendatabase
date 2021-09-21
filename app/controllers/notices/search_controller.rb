class Notices::SearchController < SearchController
  EACH_SERIALIZER = NoticeSerializerProxy
  URL_ROOT = 'notices'.freeze
  SEARCHED_MODEL = Notice

  private

  def set_model_specific_variables
    @model_class = Notice
    @search_index_path = notices_search_index_path
    @searchable_fields = Notice::SEARCHABLE_FIELDS
    @filterable_fields = Notice::FILTERABLE_FIELDS
    @ordering_options = Notice::ORDERING_OPTIONS
    @url_root = URL_ROOT
    @search_all_placeholder = 'Search all notices...'
  end

  def item_searcher
    ElasticsearchQuery.new(params).tap do |searcher|
      Notice::SEARCHABLE_FIELDS.each do |searched_field|
        searcher.register searched_field
      end

      Notice::FILTERABLE_FIELDS.each do |filtered_field|
        searcher.register filtered_field
      end

      searcher.sort_by = sort_by(params[:sort_by]) if params[:sort_by]
    end
  end
end
