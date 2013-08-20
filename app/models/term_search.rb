class TermSearch

  attr_reader :parameter, :title, :field

  def initialize(parameter, field, title = '')
    @parameter = parameter
    @field = field
    @title = title
  end

  def to_partial_path
    'notices/search/term_search'
  end

  def query_for(value)
    field = @field
    lambda do |query|
      query.must { match(field, value) }
    end
  end

  def apply_to_search(searcher, param, value)
    if handles?(param)
      searcher.query do |q|
        term_query = query_for(value)
        q.boolean &term_query
      end
    end
  end

  def register_filter(noop)
  end

  private

  def handles?(parameter_of_concern)
    @parameter == parameter_of_concern.to_sym
  end
end
