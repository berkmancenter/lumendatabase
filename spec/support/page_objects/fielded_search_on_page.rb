require_relative '../page_object'

class FieldedSearchOnPage < PageObject
  def open_advanced_search
    find("a#toggle-advanced-search").click
  end

  def within_fielded_searches(&block)
    open_advanced_search
    within('.advanced-search', &block)
  end

  def add_fielded_search_for(field, term)
    open_advanced_search
    fill_in("search-term", with: term)
    select(field, from: 'search-field')
    find('#duplicate-field').click
  end

  def run_search
    find('.advanced-search .resubmit .button').click
  end

  def visit_search_page
    visit '/notices/search'
  end

  def parameterized_search_for(field, term)
    visit "/notices/search?#{field}=#{URI.escape(term)}"
  end

  def within_results(&block)
    within('.results-list', &block)
  end

end
