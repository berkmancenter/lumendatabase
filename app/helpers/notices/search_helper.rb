module Notices::SearchHelper

  def on_behalf_of(sender_name, principal_name)
    raw %Q|#{ link_to(with_truncation(sender_name), faceted_search_path(sender_name: sender_name), class: 'sender') }
    <span class="on_behalf_of">on behalf of</span>
    #{ link_to(with_truncation(principal_name), faceted_search_path(principal_name: principal_name), class: 'principal') }|
  end

  def with_truncation(string)
    truncate(string, length: 20, omission: '…')
  end

  def formatted_facet_range_time(time)
    Time.at(time / 1000).to_datetime.to_s(:simple)
  end

  def range_facet_param(range)
    "#{range['from']}#{Notice::RANGE_SEPARATOR}#{range['to']}"
  end

  def facet_dropdown_active_indicator(type)
    if params[type].present? || params[unspecified_identifiers(type)].present?
      'active'
    end
  end

  def facet_active_indicator(type, facet_value)
    if param_matches?(type, facet_value) || param_unspecified?(type, facet_value)
      'active'
    end
  end

  def param_matches?(type, facet_value)
    params[type].present? && params[type] == facet_value
  end

  def param_unspecified?(type, facet_value)
    facet_value.blank? && params[unspecified_identifiers(type)]
  end

  def unspecified_identifiers(parameter)
    @unspecified_identifiers ||= HashWithIndifferentAccess.new do |hash, key|
      hash[key] = UnspecifiedTermFilter.unspecified_identifier(key)
    end
    @unspecified_identifiers[parameter]
  end

  def sort_order_label(sort_by_param)
    sorting = Sortings.find(sort_by_param)
    sorting.label
  end
end
