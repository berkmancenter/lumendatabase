# frozen_string_literal: true

# This model understands how to construct a query in the Elasticsearch DSL.
# It can also send that query to Elasticsearch. It returns search results in
# the format returned by Elasticsearch; it is up to the caller to do any
# further processing and data extraction.
# This should be the *only* model that understands the entire structure of
# an Elasticsearch query. However, there are helper models (also located in
# app/models/elasticsearch) which know how to produce values for particular
# keys in the query.
class SearchesModels
  attr_accessor :sort_by, :registry
  attr_reader :instances, :model_class, :params, :page, :per_page

  def initialize(params = {}, model_class = Notice)
    @sort_by = nil
    @registry = []
    @instances = []
    @model_class = model_class
    @params = params
    @page = params[:page] || 1
    @per_page = params[:per_page] || model_class::PER_PAGE
  end

  # This adds TermFilters and TermSearch to the registry. They will be processed
  # into elasticsearch query/filter language later.
  def register(filter)
    registry << filter
  end

  # This sets up the search_definition, but doesn't perform the search. It's
  # a convenience for testing purposes, allowing us to examine the prepared
  # search definition without having to mock out Elasticsearch.
  def prepare
    process_registry
    limit_to_visible_items
    convert_registry_to_elasticsearch_dsl
    add_delimiters
    define_search
  end

  # The body of the search to be sent to elasticsearch.
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

  def convert_registry_to_elasticsearch_dsl
    params.each do |param, value|
      next unless value.present?

      # Every item in the registry is expected to implement both
      # `as_elasticsearch_query` and `as_elasticsearch_filter`, but they may
      # return nil.
      registry.each do |filter|
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

        search_config[:query][:bool][:filter] << filter.as_elasticsearch_filter(param, value)
      end
    end

    search_config[:query][:bool][:must].compact!
    search_config[:query][:bool][:filter].compact!
  end

  def operator_for_param(param)
    return unless params["#{param}-require-all"].present?
    'AND'
  end

  def add_delimiters
    search_config[:processed_filters].each do |field|
      next unless @params[field[:local_parameter]].present?

      search_config[:query][:bool][:filter] <<
        delimit_by_field_parameter(field, @params[field[:local_parameter]])
    end
  end

  def delimit_by_field_parameter(field, field_param)
    delimiters = {}

    case field[:type]
    when 'terms'
      delimiters['term'] = {}
      delimiters['term'][field[:local_parameter]] = field_param
    when 'date_range'
      delimiters['range'] = {}
      val_arr = field_param.split('..')
      delimiters['range'][field[:local_parameter]] = {
        gte: val_arr[0].to_i,
        lte: val_arr[1].to_i
      }
    end

    delimiters
  end

  # ----------------------------------------------------------------------------
  # ---------------------------- SEARCH DEFINITION -----------------------------
  # ----------------------------------------------------------------------------

  # Extracts already-processed data and collates it into a search_definition
  # that elasticsearch can understand.
  def define_search
    search_definition[:query] = search_config[:query]
    search_definition[:aggregations] = Aggregator.new(search_config[:processed_filters]).value
    search_definition[:highlight] = Highlighter.new(model_class).value
    search_definition[:size] = per_page
    search_definition[:from] = this_page
    define_ordering
  end

  def define_ordering
    return unless (local_sort_by = sort_by)

    h = {}
    h[local_sort_by[0]] = {
      order: local_sort_by[1]
    }

    search_definition[:sort] = h
  end

  def this_page
    per_page.to_i * (page.to_i - 1)
  end

  def limit_to_visible_items
    return unless visible_qualifiers.any?

    visible_qualifiers.each do |k, v|
      h = {}
      h[k] = { query: v, operator: 'AND' }

      search_config[:query][:bool][:must] << { match: h }
    end
  end

  # ----------------------------------------------------------------------------
  # ----------------------------------- MISC -----------------------------------
  # ----------------------------------------------------------------------------

  # This renders our registered filters into a hash format needed by some later
  # steps of query construction (aggregation and delimiting).
  def process_registry
    registry.each do |filter|
      search_config[:processed_filters] << filter.process_for_query
    end
    search_config[:processed_filters].compact!
  end

  # A staging area for data that will ultimately be used by the search_definition
  # sent to elasticsearch.
  def search_config
    @search_config ||= {
      processed_filters: [],
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
