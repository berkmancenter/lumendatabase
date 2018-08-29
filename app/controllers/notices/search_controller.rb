class Notices::SearchController < ApplicationController
  layout 'search'

  def index
    respond_to do |format|
      format.html do
        @searcher = notice_searcher
      end
      format.json do
        searcher = notice_searcher
        raw_response = searcher.search
        raw_results = raw_response.results
        results = searcher.instances

        render(
          json: results,
          each_serializer: NoticeSerializerProxy,
          serializer: ActiveModel::ArraySerializer,
          root: 'notices',
          meta: meta_hash_for(raw_results)
        )
      end
    end
  end

  private

  def notice_searcher
    SearchesModels.new(params).tap do |searcher|
      Notice::SEARCHABLE_FIELDS.each do |searched_field|
        searcher.register searched_field
      end

      Notice::FILTERABLE_FIELDS.each do |filtered_field|
        searcher.register filtered_field
      end

      searcher.sort_by = sort_by(params[:sort_by]) if params[:sort_by]
    end
  end

  def sort_by(sort_by_param)
    sorting = Sortings.find(sort_by_param)
    sorting.sort_by
  end
end
