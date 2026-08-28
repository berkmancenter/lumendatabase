# frozen_string_literal: true

class Lumen::Search::TermSearch

  attr_reader :parameter, :title, :field

  def initialize(parameter, field, title = '')
    @parameter = parameter
    @field = field
    @title = title
  end

  def to_partial_path
    'search/term_search'
  end

  def query_for(value, operator, minimum_should_match: nil, analyzer: nil)
    operator ||= 'OR'

    query_hash = {}
    if @field.is_a?(Array)
      query_hash = {
        query: value,
        fields: @field.map(&:to_s),
        operator: operator
      }

      query_hash[:minimum_should_match] = minimum_should_match if minimum_should_match.present?
      query_hash[:analyzer] = analyzer if analyzer.present?

      if operator == 'AND' || minimum_should_match.present?
        query_hash[:type] = :cross_fields
      end

      { multi_match: query_hash }
    else
      query_hash[@field] = { query: value, operator: operator }
      query_hash[@field][:minimum_should_match] = minimum_should_match if minimum_should_match.present?
      query_hash[@field][:analyzer] = analyzer if analyzer.present?

      { match: query_hash }
    end
  end

  def as_elasticsearch_filter(*); end

  def as_elasticsearch_query(param, value, operator, minimum_should_match: nil, analyzer: nil)
    return nil unless handles?(param)

    query = []

    if value.is_a?(Array)
      value.each do |sub_val|
        query << query_for(
          sub_val,
          operator,
          minimum_should_match: minimum_should_match,
          analyzer: analyzer
        )
      end
    else
      query << query_for(
        value,
        operator,
        minimum_should_match: minimum_should_match,
        analyzer: analyzer
      )
    end

    query
  end

  def process_for_query; end

  private

  def handles?(parameter_of_concern)
    @parameter == parameter_of_concern.to_sym
  end
end
