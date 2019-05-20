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

  def apply_to_search(*)
  end

  def apply_to_query(query, param, value, operator)
    if handles?(param)
      if value.is_a?(Array)
        value.each do |sub_val|
          apply_to_query_single(query, sub_val, operator)
        end
      else
        apply_to_query_single(query, value, operator)
      end
    end
  end

  def apply_to_query_single(query, value, operator)
    term_query = query_for(value, operator)

    query[:bool][:must] << term_query
  end

  def register_filter(*)
  end

  private

  def handles?(parameter_of_concern)
    @parameter == parameter_of_concern.to_sym
  end
end
