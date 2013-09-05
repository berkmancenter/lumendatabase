require_relative '../page_object'

class FieldedSearchOnPage < PageObject
  def open_advanced_search
    unless advanced_search_visible?
      find("a#toggle-advanced-search").click
    end
  end

  def add_more
    find('#duplicate-field').click
  end

  def within_fielded_searches(&block)
    open_advanced_search

    within('.advanced-search', &block)
  end

  def within_last_field(&block)
    # note: :last-of-type in the selector does not work.
    field_group = all('.field-group').last

    within(field_group, &block)
  end

  def add_fielded_search_for(field, term)
    open_advanced_search

    add_more

    within_last_field do
      select(field.title, from: 'search-field')
      fill_in(field.parameter, with: term)
    end
  end

  def set_sort_order(sort_order)
    open_sort_order_menu
    find("a[data-value='#{sort_order}']").click
  end

  def open_sort_order_menu
    unless sort_order_visible?
      find(".sort-order a.dropdown-toggle").click
    end
  end

  def change_field(from, to)
    within(".field-group.#{from}") do
      select(to, from: 'search-field')
    end
  end

  def remove_fielded_search_for(field)
    open_advanced_search

    within(".field-group.#{field}") do
      find(".remove-group").click
    end
  end

  def run_search(wait_for_index = true)
    wait_for_index and sleep 1

    find('.advanced-search .resubmit .button').click
  end

  def visit_search_page(wait_for_index = false)
    wait_for_index and sleep 1

    visit '/notices/search'
  end

  def parameterized_search_for(field, term)
    sleep 1

    visit "/notices/search?#{field}=#{URI.escape(term)}"
  end

  def within_results(&block)
    within('.results-list', &block)
  end

  private

  def advanced_search_visible?
    first('.container.advanced-search')
  end

  def sort_order_visible?
    first('.sort-order ol.dropdown-menu')
  end
end
