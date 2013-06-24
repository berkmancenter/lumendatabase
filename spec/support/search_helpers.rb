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

  def submit_facetted_search(term, facet, facet_value)
    sleep 0.5 # required for indexing to complete

    visit '/'

    fill_in 'search', with: term
    click_on 'submit'

    within("ol.#{facet}") do
      find('a', text: /#{facet_value}/).click
    end
  end

  def within_facetted_search_results_for(term, facet, facet_value)
    submit_facetted_search(term, facet, facet_value)

    within('.search-results') do
      yield if block_given?
    end
  end

  def have_n_results(count)
    have_css('.result', count: count)
  end

end
