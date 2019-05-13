# frozen_string_literal: true

class TermFilter

  attr_reader :title, :parameter

  def initialize(parameter, title = '', indexed_attribute = nil)
    @parameter = parameter
    @title = title
    @indexed_attribute = indexed_attribute || parameter
  end

  def to_partial_path
    'notices/search/term_filter'
  end

  def filter_for(value)
    [:terms, @indexed_attribute => [value]]
  end

  def apply_to_search(searcher, param, value)
    if handles?(param)
      term_filter = filter_for(value)
      searcher[:filters] << term_filter
    end
  end

  def register_filter(searcher)
    local_indexed_attribute = @indexed_attribute
    local_parameter = @parameter

    searcher[:registered_filters] << {
      type: 'terms',
      local_parameter: local_parameter,
      local_indexed_attribute: local_indexed_attribute
    }
  end

  def apply_to_query(*)
  end

  private

  def handles?(parameter_of_concern)
    @parameter == parameter_of_concern.to_sym
  end

end
