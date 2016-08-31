class Entities::SearchController < ApplicationController

  def index
    search = entity_searcher.search
    @results = search.results

    respond_to do |format|
      format.json do
        render(
          json: @results,
          each_serializer: EntitySerializer,
          serializer: ActiveModel::ArraySerializer,
          root: 'entities',
          meta: meta_hash_for(@results)
        )
      end
    end
  end

  private

  def entity_searcher
    SearchesModels.new(params, Entity).tap do |searcher|
      if can?(:search, Entity)
        searcher.register TermSearch.new(:term, :_all)
      else
        searcher.register TermSearch.new(:term, [:name, :country_code, :url])
      end
    end
  end

end
