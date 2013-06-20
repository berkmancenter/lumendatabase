module SearchHelper
  def each_highlight(result, &block)
    if highlighted_item = result.highlight
      Notice::HIGHLIGHTS.each do |highlighted_field|
        (highlighted_item.send(highlighted_field) || []).each(&block)
      end
    end
  end

  def formatted_facet_range_time(time)
    Time.at(time / 1000).to_datetime.to_s(:simple)
  end

  def range_facet_param(range)
    "#{range['from']}#{Notice::RANGE_SEPARATOR}#{range['to']}"
  end

  def facet_dropdown_active_indicator(type)
    if params[type].present?
      'active'
    end
  end

  def facet_active_indicator(type, facet_value)
    if params[type].present? && params[type] == facet_value
      'active'
    end
  end
end
