class SearchesController < ApplicationController

  def show
    q = params[:q]
    p = params[:page]

    @results = Notice.search(page: p) do
      query { match(:_all, q) }

      facet :submitter_name do
        terms :submitter_name_facet
      end

      facet :recipient_name do
        terms :recipient_name_facet
      end

      facet :categories do
        terms :category_facet
      end

      facet :date_received do
        range :date_received, [
          { from: Time.now - 1.day, to: Time.now },
          { from: Time.now - 1.month, to: Time.now },
          { from: Time.now - 6.months, to: Time.now},
          { from: Time.now - 12.months, to: Time.now}
        ]
      end

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
