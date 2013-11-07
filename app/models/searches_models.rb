class SearchesModels

  attr_accessor :sort_by

  def initialize(params = {}, model_class = Notice)
    @params = params
    @page = params[:page] || 1
    @model_class = model_class
    @per_page = params[:per_page] || model_class::PER_PAGE
  end

  def register(filter)
    registry << filter
  end

  def registry
    @registry ||= []
  end

  def search
    Tire.search(@model_class.index_name).tap do |search|
      register_filters(search)

      if parameters_present?
        # avoid sending an empty query to elasticsearch
        apply_filters(search)
      end

      search.highlight(*@model_class::HIGHLIGHTS)
      search.size @per_page
      search.from this_page

      if local_sort_by = sort_by
        search.sort { by(*local_sort_by) }
      end
    end
  end

  def cache_key
    "search-result-#{Digest::MD5.hexdigest(@params.to_param)}"
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

    search.query do |query|
      @params.each do |param, value|
        if value.present?
          registry.each do |filter|
            filter.apply_to_query(query, param, value, operator_for_param(param))
            filter.apply_to_search(search, param, value)
          end
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
end
