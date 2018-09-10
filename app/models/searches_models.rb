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
    search_config = {
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

    register_filters(search_config)
    apply_filters(search_config)
    setup_aggregations(search_config)
    setup_highlight(search_config)

    search_definition = {}
    search_definition[:query] = search_config[:query]
    search_definition[:aggregations] = search_config[:aggregations]
    search_definition[:highlight] = search_config[:highlight]
    search_definition[:size] = @per_page
    search_definition[:from] = this_page
    if (local_sort_by = sort_by)
      h = {}
      h[local_sort_by[0]] = {
        order: local_sort_by[1]
      }
      search_definition[:sort] = h
    end

    search_response = @model_class.__elasticsearch__
                                  .search(search_definition, type: '')
    search_response.limit(@per_page)

    @instances = search_response
                 .results
                 .map { |r| NoticeSearchResult.new(get_model_class(r._source).new || Notice.new, r._source, r[:highlight].presence || []) }

    search_response
  end

  def cache_key
    "search-result-#{Digest::MD5.hexdigest(@params.to_param)}"
  end

  def visible_qualifiers
    return @model_class.visible_qualifiers if @model_class.respond_to?(:visible_qualifiers)
    {}
  end

  private

  def this_page
    @per_page.to_i * (@page.to_i - 1)
  end

  def register_filters(search)
    registry.each do |filter|
      filter.register_filter(search)
    end
  end

  def apply_filters(search)
    if @model_class.respond_to?(:add_default_filter)
      @model_class.add_default_filter(search)
    end

    if visible_qualifiers.any?
      visible_qualifiers.each do |k, v|
        h = {}
        h[k] = { query: v, operator: 'AND' }

        search[:query][:bool][:must] << { match: h }
      end
    end

    @params.each do |param, value|
      if value.present?
        registry.each do |filter|
          filter.apply_to_query(search[:query], param, value, operator_for_param(param))
          filter.apply_to_search(search, param, value)
        end
      end
    end
  end

  def operator_for_param(param)
    if @params["#{param}-require-all"].present?
      'AND'
    end
  end

  def parameters_present?
    Notice::SEARCHABLE_FIELDS.any? do |field|
      @params.key?(field.parameter) &&
        @params[field.parameter].present?
    end
  end

  def setup_aggregations(search_config)
    search_config[:registered_filters].each do |field|
      h = {}
      h[field[:type]] = {
        field: field[:local_parameter]
      }

      if field[:type] == 'date_range'
        h[field[:type]][:ranges] = field[:local_ranges]
      end

      search_config[:aggregations][field[:local_parameter]] = h

      if @params[field[:local_parameter]]
        if field[:type] == 'terms'
          h_val = {}
          h_val['term'] = {}
          h_val['term'][field[:local_parameter]] = @params[field[:local_parameter]]
          search_config[:query][:bool][:filter] << h_val
        else
          # date ranges
          h_val = {}
          h_val['range'] = {}
          val_arr = @params[field[:local_parameter]].split('..')
          h_val['range'][field[:local_parameter]] = {
            gte: val_arr[0].to_i,
            lte: val_arr[1].to_i
          }
          search_config[:query][:bool][:filter] << h_val
        end
      end
    end
  end

  def setup_highlight(search_config)
    @model_class::HIGHLIGHTS.each do |highlight_field|
      search_config[:highlight][:fields][highlight_field] = {
        type: 'plain',
        require_field_match: false
      }
    end
  end

  def get_model_class(result)
    result.has_key?('class_name') &&
    result['class_name'].classify.constantize
  end
end
