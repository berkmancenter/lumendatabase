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
    [:terms, @indexed_attribute => [ value ]]
  end

  def apply_to_search(searcher, param, value)
    if handles?(param)
      term_filter = filter_for(value)
      searcher.filter *term_filter
    end
  end

  def register_filter(searcher)
    # These must be local variables to be passed into the Tire searcher
    local_indexed_attribute = @indexed_attribute
    local_parameter = @parameter

    searcher.facet local_parameter do
      terms local_indexed_attribute
    end
  end

  private

  def handles?(parameter_of_concern)
    @parameter == parameter_of_concern.to_sym
  end

end
