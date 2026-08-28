# frozen_string_literal: true

# This model understands how to construct a query in the Elasticsearch DSL.
# It can also send that query to Elasticsearch. It returns search results in
# the format returned by Elasticsearch; it is up to the caller to do any
# further processing and data extraction.
# This should be the *only* model that understands the entire structure of
# an Elasticsearch query. However, there are helper models (also located in
# app/models/Elasticsearch) which know how to produce values for particular
# keys in the query.
class Lumen::Search::Query
  CACHE_KEY_EXCLUDED_PARAMS = %w[
    authentication_token commit format
    g-recaptcha-response g-recaptcha-response-data utf8
  ].freeze
  PROGRESSIVE_TERM_MINIMUM_WORDS = 5
  # 1-4 terms: 1; 5-8: all but 3; 9-12: all but 4;
  # 13-20: all but 5; 21 or more: 75%.
  PROGRESSIVE_TERM_MINIMUM_SHOULD_MATCH = '0<1 4<-3 8<-4 12<-5 20<75%'.freeze
  PROGRESSIVE_TERM_SEARCH_ANALYZER = 'standard'.freeze

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
    @term_exact_search = quoted_term_search? || full_url_search? || www_domain_search?
  end

  # This adds TermFilters and TermSearches to the registry. They will be
  # processed into Elasticsearch filter/query language later.
  def register(query_element)
    case query_element
    when Lumen::Search::TermFilter  # includes Lumen::Search::UnspecifiedTermFilter
      registry[:filters] << query_element
    when Lumen::Search::DateRangeFilter
      registry[:filters] << query_element
    when Lumen::Search::TermSearch
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
    limit_to_enterprise_domains
    define_search
    apply_term_exact_search
  end

  # The body of the search to be sent to Elasticsearch.
  def search_definition
    @search_definition ||= {'_source': ['score', 'id', 'title']}
  end

  def search
    prepare

    search_response = model_class.__elasticsearch__
                                  .search(search_definition)
    search_response.limit(per_page)

    search_response
  end

  def restrict_to_enterprise_domains(domains)
    @enterprise_domain_restricted = true
    @enterprise_domains = Array(domains).map { |domain| EnterpriseDomain.normalize(domain) }.reject(&:blank?).uniq
  end

  # The date is part of the cache key because our filesystem cache does not have
  # a proper cache expiration strategy; we're just deleting everything
  # periodically unless it's been recently accessed. However, this means that
  # files which are very frequently accessed can stick around in the cache
  # forever, which makes it impossible to redact things from search results.
  # Adding a datestamp guarantees that the cache_key eventually expires.
  def cache_key
    @cache_key ||= begin
      user = Current.user
      digest_values = {
        model: model_class.name,
        params: canonical_cache_value(cache_key_params),
        enterprise: user&.enterprise_cache_key,
        enterprise_domains: Array(@enterprise_domains).sort,
        super_admin: user&.role?(:super_admin)
      }
      digest = Digest::SHA256.hexdigest(JSON.generate(digest_values))

      "search-result-v2-#{digest}-#{Date.current}"
    end
  end

  private

  def cache_key_params
    raw_params = if params.respond_to?(:to_unsafe_h)
                   params.to_unsafe_h
                 else
                   params.to_h
                 end

    raw_params.stringify_keys.except(*CACHE_KEY_EXCLUDED_PARAMS)
  end

  def canonical_cache_value(value)
    if value.respond_to?(:to_unsafe_h)
      canonical_cache_value(value.to_unsafe_h)
    elsif value.is_a?(Hash)
      value.stringify_keys.sort.to_h do |key, nested_value|
        [key, canonical_cache_value(nested_value)]
      end
    elsif value.is_a?(Array)
      value.map { |nested_value| canonical_cache_value(nested_value) }
    else
      value
    end
  end

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
    registry[:searches].each do |term_search|
      operator = operator_for_param(param)
      minimum_should_match = progressive_minimum_should_match(param, value, operator)
      analyzer = if minimum_should_match.present?
                   PROGRESSIVE_TERM_SEARCH_ANALYZER
                 end
      query = term_search.as_elasticsearch_query(
        param,
        value,
        operator,
        minimum_should_match: minimum_should_match,
        analyzer: analyzer
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

  def progressive_minimum_should_match(param, value, operator)
    return if operator.present?
    return unless param.to_s == 'term'
    return unless value.is_a?(String)
    return if @term_exact_search || exact_domain_or_url_search?
    return if value.scan(/[[:alnum:]]+/).size < PROGRESSIVE_TERM_MINIMUM_WORDS

    PROGRESSIVE_TERM_MINIMUM_SHOULD_MATCH
  end

  # These are term-level queries, which require exact matches of desired data
  # within a given field. From ES 6.8 docs, "You can use term-level queries to
  # find documents based on precise values in structured data."
  def add_exact_match_requirements
    search_config[:processed_elements].each do |field|
      next unless @params[field[:local_parameter]].present?
      next if field[:local_parameter] != field[:local_indexed_attribute]

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
    search_definition[:aggregations] = Lumen::Search::Aggregator.new(search_config[:processed_elements]).value
    search_definition[:highlight] = Lumen::Search::Highlighter.new(model_class).value
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

  def limit_to_enterprise_domains
    return unless @enterprise_domain_restricted

    if @enterprise_domains.blank?
      search_config[:query][:bool][:filter] << { term: { id: '__no_enterprise_domains__' } }
      return
    end

    domain_queries = @enterprise_domains.map do |domain|
      { match_phrase: { 'works.infringing_urls.url': domain } }
    end

    search_config[:query][:bool][:filter] << {
      bool: {
        should: domain_queries,
        minimum_should_match: 1
      }
    }
  end

  def apply_term_exact_search
    return unless @term_exact_search

    search_definition[:query][:bool][:must].map! do |query_item|
      multi_match = query_item[:multi_match]
      next query_item if multi_match.nil?

      multi_match[:type] = :phrase
      if exact_url_search_fields?(multi_match)
        catch_all_multi_match = multi_match.deep_dup
        add_exact_search_highlight_query(multi_match)
        multi_match[:fields] = model_class::EXACT_URL_SEARCH_FIELDS

        if exact_subdomain_search?
          query_item = {
            bool: {
              should: [
                query_item,
                { multi_match: catch_all_multi_match }
              ],
              minimum_should_match: 1
            }
          }
        end
      end

      query_item
    end
  end

  def exact_url_search_fields?(multi_match)
    return false unless model_class.const_defined?(:EXACT_URL_SEARCH_FIELDS, false)
    return false unless model_class.const_defined?(:MULTI_MATCH_FIELDS, false)
    return false unless exact_domain_or_url_search?

    multi_match[:fields] == model_class::MULTI_MATCH_FIELDS
  end

  def exact_domain_or_url_search?
    exact_search_domain.present?
  end

  def exact_search_domain
    return @exact_search_domain if defined?(@exact_search_domain)

    value = exact_search_value
    value_for_parsing = if value.match?(%r{\A[a-z][a-z0-9+\-.]*://}i)
                          value
                        else
                          "http://#{value}"
                        end
    uri = Addressable::URI.parse(value_for_parsing)
    return @exact_search_domain = nil if uri.host.blank?
    return @exact_search_domain = nil if uri.user.present?

    @exact_search_domain = PublicSuffix.parse(uri.host, default_rule: nil)
  rescue Addressable::URI::InvalidURIError,
         PublicSuffix::DomainInvalid,
         PublicSuffix::DomainNotAllowed
    @exact_search_domain = nil
  end

  def exact_search_value
    term = @params['term'].to_s

    quoted_term_search? ? term[1...-1] : term
  end

  def quoted_term_search?
    term = @params['term']

    term.present? && term.start_with?('"') && term.end_with?('"')
  end

  # A pasted full URL is unambiguous enough to use exact-search semantics
  # without requiring the user to wrap it in quotes first. This avoids running
  # the expensive catch-all URL analyzer across the whole index.
  def full_url_search?
    return false if quoted_term_search?
    return false unless exact_search_value.match?(%r{\A[a-z][a-z0-9+\-.]*://}i)

    exact_search_domain.present?
  end

  # A conventional www hostname is indexed as one standard token even when it
  # appears in a full URL, so it can bypass the catch-all analyzer safely. Bare
  # domains retain the catch-all behavior because they may be suffix searches
  # for longer hostnames (for example, harvard.edu for gogo-team.harvard.edu).
  def www_domain_search?
    return false if quoted_term_search?
    return false unless exact_search_value.match?(%r{\Awww\.}i)

    domain = exact_search_domain
    return false if domain.nil?
    return false unless exact_search_value.casecmp?(domain.to_s)

    domain.trd.present? && domain.trd.casecmp?('www')
  end

  # The standard analyzer can join a subdomain to the label before it in a
  # stored full URL. Keep the catch-all phrase as a fallback for domain suffixes
  # such as r2.cloudflarestorage.com.
  def exact_subdomain_search?
    !www_domain_search? &&
      !exact_search_value.match?(%r{\A[a-z][a-z0-9+\-.]*://}i) &&
      exact_search_domain.trd.present?
  end

  # Highlighting only runs against the returned page, so the existing catch-all
  # phrase query remains useful there without evaluating its pathological URL
  # tokenization across the whole index.
  def add_exact_search_highlight_query(multi_match)
    search_definition[:highlight][:highlight_query] = {
      multi_match: multi_match.deep_dup
    }
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
