require_relative '../page_object'

class FieldedSearchOnPage < PageObject
  def open_advanced_search
    unless advanced_search_visible?
      find("a#toggle-advanced-search").click
    end
  end

  def within_template_row(&block)
    open_advanced_search
    within('.template-row', &block)
  end

  def within_fielded_searches(&block)
    open_advanced_search
    within('.advanced-search', &block)
  end

  def add_fielded_search_for(field, term)
    open_advanced_search
    within('.template-row') do
      fill_in("search-term", with: term)
      select(field, from: 'search-field')
    end
    find('#duplicate-field').click
  end

  def change_field(from, to)
    within(".field-group.#{from}") do
      select(to, from: 'search-field')
    end
  end

  def remove_fielded_search_for(field)
    open_advanced_search
    find(".remove-group.#{field}").click
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

end
