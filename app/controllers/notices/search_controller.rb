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
    @facet_search_index_path = facet_notices_search_index_path
  end

  def item_searcher
    ElasticsearchQuery.new(params).tap do |searcher|
      Notice::SEARCHABLE_FIELDS.each do |searched_field|
        searcher.register searched_field
      end

      # Facets in the html format will be provided on request from the UI
      if request.format.json?
        Notice::FILTERABLE_FIELDS.each do |filtered_field|
          searcher.register filtered_field
        end
      end

      if request.format.html?
        Notice::FILTERABLE_FIELDS.each do |filtered_field|
          searcher.register filtered_field if params[filtered_field.parameter]
        end
      end

      searcher.sort_by = sort_by(params[:sort_by]) if params[:sort_by]
    end
  end
end
