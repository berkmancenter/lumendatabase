class Notices::SearchController < SearchController
  EACH_SERIALIZER = NoticeSerializerProxy
  URL_ROOT = 'notices'.freeze
  SEARCHED_MODEL = Notice

  private

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
