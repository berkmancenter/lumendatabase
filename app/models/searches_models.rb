# frozen_string_literal: true

class SearchesModels
  attr_accessor :sort_by
  attr_reader :instances, :page

  def initialize(params = {}, model_class = Notice)
    @params = params
    @page = params[:page] || 1
    @model_class = model_class
    @per_page = params[:per_page] || model_class::PER_PAGE
    @instances = []
  end

  def register(filter)
    registry << filter
  end

  def registry
    @registry ||= []
  end

  def search
    register_filters
    apply_filters
    setup_aggregations
    setup_highlight
    parametrize_search
    define_ordering

    search_response = @model_class.__elasticsearch__
                                  .search(search_definition, type: '')
    search_response.limit(@per_page)

    search_response
  end

  def cache_key
    @cache_key ||= "search-result-#{Digest::MD5.hexdigest(@params.to_param)}"
  end

  def visible_qualifiers
    if @model_class.respond_to?(:visible_qualifiers)
      @model_class.visible_qualifiers
    else
      {}
    end
  end

  private

  def add_field_type_to_config(field)
    h = {}
    h[field[:type]] = {
      field: field[:local_parameter]
    }

    if field[:type] == 'date_range'
      h[field[:type]][:ranges] = field[:local_ranges]
    end

    search_config[:aggregations][field[:local_parameter]] = h
  end

  def apply_filters
    apply_default_filter
    apply_visible_qualifiers
    apply_params_to_registered_filters
  end

  def apply_default_filter
    return unless @model_class.respond_to?(:add_default_filter)
    @model_class.add_default_filter(search_config)
  end

  def apply_params_to_registered_filters
    @params.each do |param, value|
      next unless value.present?

      registry.each do |filter|
        filter.apply_to_query(search_config[:query],
                              param,
                              value,
                              operator_for_param(param))
        filter.apply_to_search(search_config, param, value)
      end
    end
  end

  def apply_visible_qualifiers
    return unless visible_qualifiers.any?

    visible_qualifiers.each do |k, v|
      h = {}
      h[k] = { query: v, operator: 'AND' }

      search_config[:query][:bool][:must] << { match: h }
    end
  end

  def define_ordering
    return unless (local_sort_by = sort_by)
    h = {}
    h[local_sort_by[0]] = {
      order: local_sort_by[1]
    }
    search_definition[:sort] = h
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

  def get_model_class(result)
    result.key?('class_name') &&
      result['class_name'].classify.constantize
  end

  def operator_for_param(param)
    return unless @params["#{param}-require-all"].present?
    'AND'
  end

  def parameters_present?
    Notice::SEARCHABLE_FIELDS.any? do |field|
      @params.key?(field.parameter) &&
        @params[field.parameter].present?
    end
  end

  def parametrize_search
    search_definition[:query] = search_config[:query]
    search_definition[:aggregations] = search_config[:aggregations]
    search_definition[:highlight] = search_config[:highlight]
    search_definition[:size] = @per_page
    search_definition[:from] = this_page
  end

  def register_filters
    registry.each do |filter|
      filter.register_filter(search_config)
    end
  end

  def search_config
    @search_config ||= {
      registered_filters: [],
      filters: [],
      query: {
        bool: {
          must: [],
          filter: []
        }
      },
      aggregations: {},
      highlight: {
        pre_tags: '<em>',
        post_tags: '</em>',
        fields: {}
      }
    }
  end

  def search_definition
    @search_definition ||= {'_source': ['score', 'id', 'title']}
  end

  def setup_aggregations
    search_config[:registered_filters].each do |field|
      add_field_type_to_config(field)

      next unless @params[field[:local_parameter]].present?

      search_config[:query][:bool][:filter] <<
        delimit_by_field_parameter(field, @params[field[:local_parameter]])
    end
  end

  def setup_highlight
    @model_class::HIGHLIGHTS.each do |highlight_field|
      search_config[:highlight][:fields][highlight_field] = {
        type: 'plain',
        require_field_match: false
      }
    end
  end

  def this_page
    @per_page.to_i * (@page.to_i - 1)
  end
end
