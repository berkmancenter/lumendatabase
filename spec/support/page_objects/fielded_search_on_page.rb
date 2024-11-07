require_relative '../page_object'

class FieldedSearchOnPage < PageObject
  def open_advanced_search
    has_selector?('.container.advanced-search', visible: :all)
    node = first('.container.advanced-search', visible: :all)
    find('a#toggle-advanced-search').click unless node.visible?
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

  def limit_search_to_all_words_for(field)
    within(".field-group.#{field.field}") do
      check 'All words required'
    end
  end

  def define_sort_order(sort_order)
    open_sort_order_menu
    find("a[data-value='#{sort_order}']").click
  end

  def open_sort_order_menu
    menu = first('.sort-order ol.dropdown-menu', visible: :all)
    find('.sort-order a.dropdown-toggle').click unless menu.visible?
  end

  def change_field(from, to)
    within(".field-group.#{from}") do
      select(to, from: 'search-field')
    end
  end

  def remove_fielded_search_for(field)
    open_advanced_search

    within(".field-group.#{field}") do
      find('.remove-group').click
    end
  end

  def run_search
    find('.advanced-search .resubmit .button').click
  end

  def visit_search_page
    visit '/notices/search'
  end

  def parameterized_search_for(field, term)
    visit "/notices/search?#{field}=#{CGI.escape(term)}"
  end

  def within_results(&block)
    within('.results-list', &block)
  end
end
