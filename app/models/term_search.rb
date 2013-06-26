class TermSearch

  def initialize(parameter, field)
    @parameter = parameter
    @field = field
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
