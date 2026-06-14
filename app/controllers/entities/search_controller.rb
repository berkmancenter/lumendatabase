class Entities::SearchController < SearchController
  EACH_SERIALIZER = EntitySerializer
  URL_ROOT = 'entities'.freeze
  SEARCHED_MODEL = Entity

  private

  def html_responder
    redirect_to root_path
  end

  def item_searcher
    Lumen::Search::Query.new(params, Entity).tap do |searcher|
      if can?(:search, Entity)
        searcher.register Lumen::Search::TermSearch.new(:term, Entity::MULTI_MATCH_FIELDS)
      else
        searcher.register Lumen::Search::TermSearch.new(:term, %i[name^5 country_code url])
      end
    end
  end
end
