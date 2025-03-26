# This class abstracts common functionality of Notices::SearchController and
# Entities::SearchController. It is not meant to be used on its own. It should
# be subclassed, and subclasses must define the following:
# - EACH_SERIALIZER
# - URL_ROOT
# - SEARCHED_MODEL
# - item_searcher
# - set_model_specific_variables
# They may also define html_responder.
class SearchController < ApplicationController
  before_action :set_model_specific_variables
  before_action :prevent_impossible_pagination
  before_action :restrict_deep_pagination

  layout 'search'

  EACH_SERIALIZER = nil
  URL_ROOT = nil

  def index
    if request.format.html? && current_user.nil? && !Rails.env.test? && !@skip_captcha
      unless captcha_permitted?
        redirect_to(captcha_gateway_index_path(destination: CGI.escape(request.original_url))) and return
      end
    end

    @searcher = item_searcher
    @searchdata = @searcher.search
    @wrapped_instances = wrap_instances

    LumenLogger.log_metrics('SEARCHED', search_details: meta_hash_for(@searchdata).except(:facets))

    respond_to do |format|
      format.html { html_responder }
      format.json { json_renderer }
    end
  end

  def facet
    filterable_field_facet = @filterable_fields.find { |field| field.parameter.to_s == params[:facet_id] }

    resource_not_found and return if filterable_field_facet.nil?

    @searcher = ElasticsearchQuery.new(params, @model_class).tap do |searcher|
      @searchable_fields.each do |searched_field|
        searcher.register searched_field
      end

      searcher.register(filterable_field_facet)
    end

    @searchdata = @searcher.search

    render filterable_field_facet, locals: { results: @searchdata.response['aggregations'] }
  end

  private

  def captcha_permitted?
    return false unless session[:captcha_permission]

    time_permission = session[:captcha_permission]
    time_permission > Time.now
  end

  def html_responder; end

  def item_searcher; end

  def json_renderer
    # The self.class incantation is necessary to make instances look up their
    # subclass overrides to these constants, rather than pulling in the
    # original definition.
    render(
      json: {
        self.class::URL_ROOT => @wrapped_instances.map { |instance| self.class::EACH_SERIALIZER.new(instance) },
        meta: meta_hash_for(@searchdata)
      }
    )
  end

  # Enrich the activerecord object with search-related metadata for display.
  # Return the enriched instance (or nil, if none was found).
  def augment_instance(instance)
    return unless instance.present?

    result = @searchdata.select { |datum| datum[:_id] == instance.id.to_s }.first

    class << instance
      attr_accessor :_score, :highlight
    end

    instance._score = result[:_score]

    highlights = result[:highlight].presence || []
    instance.highlight = highlights.map { |h| h[1] }.flatten

    instance
  end

  def sort_by(sort_by_param)
    ResultOrdering.define(sort_by_param, @model_class).sort_by
  end

  def wrap_instances
    # #records fetches the database instances while maintaining the search
    # response ordering.
    # Note that the search definition above is lazy; this is the first line
    # where anything with Elasticsearch actually gets executed.
    instances = @searchdata.records
    instances.map { |r| augment_instance(r) }
  end

  # Elasticsearch cannot return more than 20_000 results in production (2000
  # pages at 10 results per page).
  def prevent_impossible_pagination
    return if num_results < 20_001

    render 'shared/_error',
           status: :not_found,
           locals: {
             message: 'Lumen cannot display beyond the 20,000th result. ' \
                      'Try a more specific query.'
           }
  end

  # Deep pagination is expensive for the CPU, so don't let anonymous users
  # do it.
  def restrict_deep_pagination
    return if pagination_allowed?

    render 'shared/_error',
           status: :unauthorized,
           locals: {
             message: 'You must be logged in to see past the first 100 ' \
                      'results. ' \
                      '<a href="https://lumendatabase.org/pages/researchers#key">Request ' \
                      'a research account key</a>.'.html_safe
           }
  end

  def pagination_allowed?
    [user_signed_in?,
     num_results < 101,
     request.format.json? && num_results < 20_001].any?
  end

  def num_results
    current_page * per_page
  end

  def meta_hash_for(results)
    meta = query_meta(results)
    total_entries = total_entries(results)
    total_pages = calculate_total_pages(total_entries)

    # Add pagination data to meta hash
    meta[:current_page] = current_page
    meta[:next_page] = calculate_next_page(total_pages)
    meta[:previous_page] = calculate_previous_page
    meta[:per_page] = per_page
    meta[:total_entries] = total_entries
    meta[:total_pages] = total_pages
    meta[:offset] = calculate_offset

    meta
  end

  def current_page
    (params[:page] || 1).to_i
  end

  def per_page
    (params[:per_page] || 10).to_i
  end

  def total_entries(results)
    results.raw_response['hits']['total']['value']
  end

  def calculate_total_pages(total_entries)
    (total_entries.to_f / per_page).ceil
  end

  def calculate_next_page(total_pages)
    current_page < total_pages ? current_page + 1 : nil
  end

  def calculate_previous_page
    current_page > 1 ? current_page - 1 : nil
  end

  def calculate_offset
    (current_page - 1) * per_page
  end

  def query_meta(results)
    {
      query: {
        term: params[:term]
      }.merge(facet_query_meta(results) || {})
    }.tap do |meta|
      # Only add facets if aggregations exist
      if results.response&.aggregations.present?
        meta[:facets] = results.response.aggregations
      end
    end
  end

  def facet_query_meta(results)
    return {} unless results.response&.aggregations&.keys

    results.response.aggregations.keys.each_with_object({}) do |facet, memo|
      memo[facet.to_sym] = params[facet.to_sym] if params[facet.to_sym].present?
    end
  end

  def set_model_specific_variables; end
end
