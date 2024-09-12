# frozen_string_literal: true

class TermFilter

  attr_reader :title, :parameter, :skip_frontend

  def initialize(parameter, title = '', indexed_attribute = nil, skip_frontend = false)
    @parameter = parameter
    @title = title
    @indexed_attribute = indexed_attribute || parameter
    @skip_frontend = skip_frontend
  end

  def to_partial_path
    'search/term_filter'
  end

  # When tests for this fail, update them to use as_elasticsearch_filter,
  # and then delete this, and make sure filter_for is handled similarly elsewhere.
  def filter_for(value)
  end

  def as_elasticsearch_filter(param, value)
    return unless handles?(param)

    { term: { @indexed_attribute => value } }
  end

  def process_for_query
    {
      type: :terms,
      local_parameter: @parameter,
      local_indexed_attribute: @indexed_attribute
    }
  end

  def as_elasticsearch_query(*); end

  private

  def handles?(parameter_of_concern)
    @parameter == parameter_of_concern.to_sym
  end

end
