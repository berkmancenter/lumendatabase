class SearchesModels

  attr_accessor :sort_by

  def initialize(params = {}, model_class = Notice)
    @params = params
    @page = params[:page] || 1
    @model_class = model_class
    @per_page = params[:per_page] || model_class::PER_PAGE
  end

  def register(search_type)
    registry << search_type
  end

  def registry
    @registry ||= []
  end

  def search
    @search = Tire.search(@model_class.index_name)
    register_filters

    @params.each do |param, value|
      if value.present?
        add_searches_for(param, value)
      end
    end

    @search.highlight(*@model_class::HIGHLIGHTS)
    @search.size @per_page
    @search.from this_page

    local_sort_by = sort_by
    if sort_by
      @search.sort{ by *local_sort_by }
    end

    @search
  end

  private

  def this_page
    @per_page.to_i * (@page.to_i - 1)
  end

  def register_filters
    registry.each do |filter|
      filter.register_filter(@search)
    end
  end

  def add_searches_for(param, value)
    registry.each do |search_type|
      search_type.apply_to_search(@search, param, value)
    end
  end

end
