# frozen_string_literal: true

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

  def query_for(value, operator)
    operator ||= 'OR'
    field = @field

    h = {}
    if field.is_a?(Array)
      h = { query: value, fields: field.map(&:to_s) }

      { multi_match: h }
    else
      h[field] = { query: value, operator: operator }

      { match: h }
    end
  end

  def as_elasticsearch_filter(*); end

  def as_elasticsearch_query(param, value, operator)
    return nil unless handles?(param)

    query = []

    if value.is_a?(Array)
      value.each do |sub_val|
        query << query_for(sub_val, operator)
      end
    else
      query << query_for(value, operator)
    end

    query
  end

  def process_for_query; end

  private

  def handles?(parameter_of_concern)
    @parameter == parameter_of_concern.to_sym
  end
end
