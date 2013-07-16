class SearchesController < ApplicationController

  def show
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

    NoticeSearcher.new(params).tap do |searcher|
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

  def meta_hash_for(results)
    %i(
      current_page next_page offset per_page
      previous_page total_entries total_pages
    ).each_with_object(query_meta(results)) do |attribute, memo|
      memo[attribute] = results.send(attribute)
    end
  end

  def query_meta(results)
    {
      query: {
        term: params[:term]
      }.merge(facet_query_meta(results)),
      facets: results.facets
    }
  end

  def facet_query_meta(results)
    results.facets.keys.each_with_object({}) do |facet, memo|
      if params[facet.to_sym].present?
        memo[facet.to_sym] = params[facet.to_sym]
      end
    end
  end
end
