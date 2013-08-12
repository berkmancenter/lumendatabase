module SearchHelpers

  def submit_search(term)
    sleep 1 # required for indexing to complete

    visit '/'

    fill_in 'search', with: term
    click_on 'submit'
  end

  def within_search_results_for(term)
    submit_search(term)
    within('.search-results') do
      yield if block_given?
    end
  end

  def open_dropdown_for_facet(facet)
    find(".dropdown-toggle.#{facet}").click
  end

  def open_and_select_facet(facet, facet_value)
    open_dropdown_for_facet(facet)

    within("ol.#{facet}") do
      find('a', text: /#{facet_value}/).click
    end
  end

  def submit_faceted_search(term, facet, facet_value)
    sleep 0.5 # required for indexing to complete

    visit '/'

    fill_in 'search', with: term
    click_on 'submit'

    open_and_select_facet(facet, facet_value)

    click_faceted_search_button
  end

  def click_faceted_search_button
    within('.search-results') do
      find('button').click
    end
  end

  def within_faceted_search_results_for(term, facet, facet_value)
    submit_faceted_search(term, facet, facet_value)

    within('.search-results') do
      yield if block_given?
    end
  end

  def have_n_results(count)
    have_css('.result', count: count)
  end

  def have_active_facet_dropdown(facet_type)
    have_css(".dropdown.#{facet_type}.active")
  end

  def have_active_facet(facet_type, facet)
    find(".dropdown-toggle.#{facet_type}").click
    have_css('.dropdown-menu li.active a', text: /^#{facet}/)
  end

end
