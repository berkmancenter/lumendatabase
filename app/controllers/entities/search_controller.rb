class Entities::SearchController < ApplicationController
  def index
    searcher = entity_searcher
    raw_response = searcher.search
    raw_results = raw_response.results
    results = searcher.instances

    respond_to do |format|
      format.json {
        render(
          json: results,
          each_serializer: EntitySerializer,
          serializer: ActiveModel::ArraySerializer,
          root: 'entities',
          meta: meta_hash_for(raw_results)
        )
      }
      format.html { redirect_to root_path }
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
