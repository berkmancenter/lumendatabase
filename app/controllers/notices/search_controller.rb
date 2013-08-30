class Notices::SearchController < ApplicationController
  layout 'search'

  def index
    search = notice_searcher.search

    @results = search.results

    respond_to do |format|
      format.html
      format.json do
        render(
          json: @results,
          each_serializer: NoticeSerializerProxy,
          serializer: ActiveModel::ArraySerializer,
          root: 'notices',
          meta: meta_hash_for(@results)
        )
      end
    end
  end

  private

  def notice_searcher
    now = Time.now.beginning_of_day

    SearchesModels.new(params).tap do |searcher|
      Notice::SEARCHABLE_FIELDS.each do |searched_field|
        searcher.register searched_field
      end

      Notice::FILTERABLE_FIELDS.each do |filtered_field|
        searcher.register filtered_field
      end

      if params[:sort_by]
        searcher.sort_by = sort_by(params[:sort_by])
      end
    end
  end

  def sort_by(sort_by_param)
    sorting = Sortings.find(sort_by_param)
    sorting.sort_by
  end

end
