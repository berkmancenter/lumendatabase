# This class abstracts common functionality of Notices::SearchController and
# Entities::SearchController. It is not meant to be used on its own. It should
# be subclassed, and subclasses must define the following:
# - EACH_SERIALIZER
# - URL_ROOT
# - SEARCHED_MODEL
# - item_searcher
# They may also define html_responder.
class SearchController < ApplicationController
  layout 'search'

  EACH_SERIALIZER = nil
  URL_ROOT = nil

  def index
    @searcher = item_searcher
    @searchdata = @searcher.search
    @wrapped_instances = wrap_instances

    respond_to do |format|
      format.html { html_responder }
      format.json { json_renderer }
    end
  end

  private

  def html_responder; end

  def item_searcher; end

  def json_renderer
    # The self.class incantation is necessary to make instances look up their
    # subclass overrides to these constants, rather than pulling in the
    # original definition.
    render(
      json: @wrapped_instances,
      each_serializer: self.class::EACH_SERIALIZER,
      serializer: ActiveModel::ArraySerializer,
      root: self.class::URL_ROOT,
      meta: meta_hash_for(@searchdata)
    )
  end

  # Find the instance in the database corresponding to the given elasticsearch
  # result and enrich it with search-related metadata for display. Return the
  # enriched instance (or nil, if no Notice was found).
  def augment_instance(result)
    instance = self.class::SEARCHED_MODEL.where(id: result._source[:id])
    return unless instance.present?

    instance = instance.first

    class << instance
      attr_accessor :_score, :highlight
    end

    instance._score = result._source['_score']

    highlights = result[:highlight].presence || []
    instance.highlight = highlights.map { |h| h[1] }.flatten

    instance
  end

  def sort_by(sort_by_param)
    sorting = Sortings.find(sort_by_param)
    sorting.sort_by
  end

  def wrap_instances
    @searchdata.results
               .map { |r| augment_instance(r) }
               .compact
  end
end
