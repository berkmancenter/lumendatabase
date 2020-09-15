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

    query_hash = {}
    if @field.is_a?(Array)
      query_hash = {
        query: value,
        fields: @field.map(&:to_s),
        operator: operator
      }

      if operator == 'AND'
        query_hash[:type] = :cross_fields
      end

      { multi_match: query_hash }
    else
      query_hash[@field] = { query: value, operator: operator }

      { match: query_hash }
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
