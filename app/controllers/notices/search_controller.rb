class Notices::SearchController < ApplicationController

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
      searcher.register TermSearch.new(:term, :_all)

      searcher.register TermFilter.new(:categories, :category_facet)
      searcher.register TermFilter.new(:sender_name, :sender_name_facet)
      searcher.register TermFilter.new(:recipient_name, :recipient_name_facet)
      searcher.register TermFilter.new(:tags, :tag_list_facet)
      searcher.register TermFilter.new(:country_code, :country_code_facet)
      searcher.register TermFilter.new(:language, :language_facet)
      searcher.register DateRangeFilter.new(
        :date_received,
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
