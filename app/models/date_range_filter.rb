class DateRangeFilter

  def initialize(parameter, ranges = [])
    @parameter = parameter
    @ranges = ranges
  end

  def apply_to_search(searcher, param, value)
    if handles?(param)
      date_range_filter = filter_for(value)
      searcher.filter *date_range_filter
    end
  end

  def register_filter(searcher)
    # These must be local variables to be passed into the Tire searcher
    local_parameter = @parameter
    local_ranges = @ranges

    searcher.facet local_parameter do
      range local_parameter, local_ranges
    end
  end

  def filter_for(value)
    filter_values = FilterRangeValues.new(value)
    [
      :range,
      @parameter => { from: filter_values.from, to: filter_values.to }
    ]
  end

  private

  def handles?(parameter_of_concern)
    @parameter == parameter_of_concern.to_sym
  end

  class FilterRangeValues
    attr_reader :from, :to

    def initialize(time_value)
      @from, @to = time_value.split(Notice::RANGE_SEPARATOR, 2).map do |str|
        Time.at(str.to_i / 1000)
      end
    end
  end

end
