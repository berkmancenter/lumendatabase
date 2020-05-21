# frozen_string_literal: true

# This model understands how to construct a query in the Elasticsearch DSL.
# It can also send that query to Elasticsearch. It returns search results in
# the format returned by Elasticsearch; it is up to the caller to do any
# further processing and data extraction.
# This should be the *only* model that understands the entire structure of
# an Elasticsearch query. However, there are helper models (also located in
# app/models/Elasticsearch) which know how to produce values for particular
# keys in the query.
class ElasticsearchQuery
  attr_accessor :sort_by, :registry
  attr_reader :instances, :model_class, :params, :page, :per_page

  def initialize(params = {}, model_class = Notice)
    @sort_by = nil
    @registry = { filters: [], searches: [] }
    @instances = []
    @model_class = model_class
    @params = params
    @page = params[:page] || 1
    @per_page = params[:per_page] || model_class::PER_PAGE
  end

  # This adds TermFilters and TermSearches to the registry. They will be
  # processed into Elasticsearch filter/query language later.
  def register(query_element)
    case query_element
    when TermFilter  # includes UnspecifiedTermFilter
      registry[:filters] << query_element
    when DateRangeFilter
      registry[:filters] << query_element
    when TermSearch
      registry[:searches] << query_element
    else
      Rails.logger.warn "Unknown query_element of class #{query_element.class}"
    end
  end

  # This sets up the search_definition, but doesn't perform the search. It's
  # a convenience for testing purposes, allowing us to examine the prepared
  # search definition without having to mock out Elasticsearch.
  def prepare
    process_registry
    limit_to_visible_items
    add_registered_elements_to_query
    add_exact_match_requirements
    define_search
  end

  # The body of the search to be sent to Elasticsearch.
  def search_definition
    @search_definition ||= {'_source': ['score', 'id', 'title']}
  end

  def search
    prepare

    search_response = model_class.__elasticsearch__
                                  .search(search_definition, type: '')
    search_response.limit(per_page)

    search_response
  end

  def cache_key
    @cache_key ||= "search-result-#{Digest::MD5.hexdigest(params.values.to_s)}"
  end

  private

  # These are full-text queries -- searches and filters -- which Elasticsearch
  # will score with a best-match algorithm.
  def add_registered_elements_to_query
    params.each do |param, value|
      next unless value.present?

      add_filters_to_elasticsearch_query(param, value)
      add_searches_to_elasticsearch_query(param, value)
    end

    # as_elasticsearch_query and as_elasticsearch_filter are defined for all
    # elements in the registry, but may return nil. Therefore we get rid of any
    # nil elements here.
    search_config[:query][:bool][:filter].compact!
    search_config[:query][:bool][:must].compact!
  end

  def add_filters_to_elasticsearch_query(param, value)
    registry[:filters].each do |filter|
      search_config[:query][:bool][:filter] << filter.as_elasticsearch_filter(param, value)
    end
  end

  def add_searches_to_elasticsearch_query(param, value)
    registry[:searches].each do |filter|
      query = filter.as_elasticsearch_query(
        param,
        value,
        operator_for_param(param)
      )

      case query
      when Array
        search_config[:query][:bool][:must].concat query
      else
        search_config[:query][:bool][:must] << query
      end
    end
  end

  def operator_for_param(param)
    return unless params["#{param}-require-all"].present?
    'AND'
  end

  # These are term-level queries, which require exact matches of desired data
  # within a given field. From ES 6.8 docs, "You can use term-level queries to
  # find documents based on precise values in structured data."
  def add_exact_match_requirements
    search_config[:processed_elements].each do |field|
      next unless @params[field[:local_parameter]].present?

      search_config[:query][:bool][:filter] <<
        create_exact_term_query(field, @params[field[:local_parameter]])
    end
  end

  def create_exact_term_query(field, value)
    exact_term_query = {}

    case field[:type]
    when :terms
      exact_term_query[:term] = { field[:local_parameter] => value }
    when :date_range
      val_arr = value.split('..')
      exact_term_query[:range] = {
        field[:local_parameter] => {
          gte: val_arr[0].to_i,
          lte: val_arr[1].to_i
        }
      }
    end

    exact_term_query
  end

  # ----------------------------------------------------------------------------
  # ---------------------------- SEARCH DEFINITION -----------------------------
  # ----------------------------------------------------------------------------

  # Extracts already-processed data and collates it into a search_definition
  # that Elasticsearch can understand.
  def define_search
    search_definition[:query] = search_config[:query]
    search_definition[:aggregations] = Aggregator.new(search_config[:processed_elements]).value
    search_definition[:highlight] = Highlighter.new(model_class).value
    search_definition[:size] = per_page
    search_definition[:from] = this_page
    search_definition[:sort] = sort_definition if sort_definition.present?
  end

  def sort_definition
    return unless sort_by.present?

    { sort_by[0] => { order: sort_by[1] } }
  end

  def this_page
    per_page.to_i * (page.to_i - 1)
  end

  def limit_to_visible_items
    return unless visible_qualifiers.any?

    visible_qualifiers.each do |k, v|
      limitation = { k => { query: v, operator: 'AND' } }

      search_config[:query][:bool][:must] << { match: limitation }
    end
  end

  # ----------------------------------------------------------------------------
  # ----------------------------------- MISC -----------------------------------
  # ----------------------------------------------------------------------------

  # This renders our registered filters into a hash format needed by some later
  # steps of query construction (aggregation and exact term matching).
  def process_registry
    (registry[:filters] + registry[:searches]).each do |query_element|
      search_config[:processed_elements] << query_element.process_for_query
    end
    search_config[:processed_elements].compact!
  end

  # A staging area for data that will ultimately be used by the search_definition
  # sent to Elasticsearch.
  def search_config
    @search_config ||= {
      processed_elements: [],
      query: {
        bool: {
          must: [],
          filter: []
        }
      }
    }
  end

  def visible_qualifiers
    if model_class.respond_to?(:visible_qualifiers)
      model_class.visible_qualifiers
    else
      {}
    end
  end
end
