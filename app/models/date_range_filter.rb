# frozen_string_literal: true

class DateRangeFilter

  attr_reader :title, :parameter

  def initialize(parameter, indexed_attribute = nil, title = '')
    @parameter = parameter
    @title = title
    @indexed_attribute = indexed_attribute || parameter
  end

  def to_partial_path
    'notices/search/date_range_filter'
  end

  def apply_to_search(searcher, param, value)
    if handles?(param)
      date_range_filter = filter_for(value)
      searcher[:filters]  << date_range_filter
    end
  end

  def register_filter(searcher)
    # These must be local variables to be passed into the Tire searcher
    local_parameter = @parameter
    local_indexed_attribute = @indexed_attribute
    local_ranges = ranges

    searcher[:registered_filters] << {
      type: 'date_range',
      local_parameter: local_parameter,
      local_indexed_attribute: local_indexed_attribute,
      local_ranges: local_ranges
    }
  end

  def filter_for(value)
    filter_values = FilterRangeValues.new(value)

    [:range, @indexed_attribute => filter_values.to_attribute]
  end


  def apply_to_query(*)
  end

  private

  def ranges
    now = Time.now.beginning_of_day
    [
      { from: now - 1.day, to: now },
      { from: now - 1.month, to: now  },
      { from: now - 6.months, to: now },
      { from: now - 12.months, to: now },
    ]
  end

  def handles?(parameter_of_concern)
    @parameter == parameter_of_concern.to_sym
  end

  class FilterRangeValues
    def initialize(time_value)
      @from, @to = time_value.split(Notice::RANGE_SEPARATOR, 2).map do |str|
        Time.at(str.to_i / 1000)
      end
    end

    def to_attribute
      { from: @from, to: @to }
    end
  end

end
