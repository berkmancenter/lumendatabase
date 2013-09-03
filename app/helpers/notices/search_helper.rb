module Notices::SearchHelper
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

  def sort_order_label(sort_by_param)
    sorting = Sortings.find(sort_by_param)
    sorting.label
  end
end
