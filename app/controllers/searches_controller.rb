class SearchesController < ApplicationController

  def show
    q = params[:q]
    p = params[:page]

    @results = Notice.search(page: p) do
      query { match(:_all, q) }

      highlight(*Notice::HIGHLIGHTS)
    end

    respond_to do |format|
      format.html{ }
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

  def meta_hash_for(results)
    %i(
      current_page next_page offset per_page
       previous_page total_entries total_pages
    ).each_with_object({ q: params['q'] }) do|attribute, memo|
      memo[attribute] = results.send(attribute)
    end
  end
end
