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
          each_serializer: NoticeSearchResultSerializer,
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
      Notice::SEARCHABLE_FIELDS.each do |field|
        searcher.register TermSearch.new(
          field[:parameter], field[:indexed_field]
        )
      end

      searcher.register TermFilter.new(:category_facet)
      searcher.register TermFilter.new(:sender_name_facet)
      searcher.register TermFilter.new(:recipient_name_facet)
      searcher.register TermFilter.new(:tag_list_facet)
      searcher.register TermFilter.new(:country_code_facet)
      searcher.register TermFilter.new(:language_facet)
      searcher.register DateRangeFilter.new(
        :date_received_facet, :date_received,
        [
          { from: now - 1.day, to: now },
          { from: now - 1.month, to: now },
          { from: now - 6.months, to: now },
          { from: now - 12.months, to: now }
        ]
      )
    end
  end

end
