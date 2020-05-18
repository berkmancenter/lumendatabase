# frozen_string_literal: true

# This class knows how to produce the value of the :aggregations key in an
# elasticsearch query hash.
class Aggregator
  def initialize(registered_filters)
    @registered_filters = registered_filters
    @aggregations = {}
  end

  def value
    setup_aggregations
    @aggregations
  end

  private

  def add_field_type_to_config(field)
    h = {}
    h[field[:type]] = { field: field[:local_parameter] }

    if field[:type] == 'date_range'
      h[field[:type]][:ranges] = field[:local_ranges]
    end

    @aggregations[field[:local_parameter]] = h
  end

  def setup_aggregations
    @registered_filters.each do |field|
      add_field_type_to_config(field)
    end
  end
end
