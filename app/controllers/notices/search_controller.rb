class Notices::SearchController < ApplicationController
  layout 'search'

  def index
    @searcher = notice_searcher
    @searchdata = @searcher.search
    @wrapped_instances = wrap_instances

    respond_to do |format|
      format.html
      format.json { json_renderer }
    end
  end

  private

  def json_renderer
    render(
      json: @wrapped_instances,
      each_serializer: NoticeSerializerProxy,
      serializer: ActiveModel::ArraySerializer,
      root: 'notices',
      meta: meta_hash_for(@searchdata)
    )
  end

  # Find the Notice in the database corresponding to the given elasticsearch
  # result and enrich it with search-related metadata for display. Return the
  # enriched Notice instance (or nil, if no Notice was found).
  def augment_notice(result)
    return unless (notice = Notice.find(result._source[:id]))

    class << notice
      attr_accessor :_score, :highlight
    end

    notice._score = result._source['_score']

    highlights = result[:highlight].presence || []
    notice.highlight = highlights.map { |h| h[1] }.flatten

    notice
  end

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

  def wrap_instances
    @searchdata.results
               .map { |r| augment_notice(r) }
               .compact
  end
end
